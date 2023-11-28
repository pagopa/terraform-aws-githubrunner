
data "aws_caller_identity" "current" {}


# Logs

# log group used by the runner
resource "aws_cloudwatch_log_group" "ecs_github_runner" {
  name = "github/runners"

  retention_in_days = var.ecs_logs_retention_days

  tags = {
    Name = "github-unner"
  }
}


# ECS task definition for the runner

# ecr repository of the github runner image
resource "aws_ecr_repository" "runner_ecr" {
  name                 = "github-runner"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
}

# cluster in which to run the task, can be created here or not
resource "aws_ecs_cluster" "ecs_cluster" {
  count = var.ecs_create_cluster ? 1 : 0

  name = var.ecs_cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity" {
  count = var.ecs_create_cluster ? 1 : 0

  cluster_name = aws_ecs_cluster.ecs_cluster[0].name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "github_runner_def" {
  family                   = var.task_name
  execution_role_arn       = aws_iam_role.task_execution_github_runner.arn
  task_role_arn            = aws_iam_role.task_github_runner.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.github_runner_cpu
  memory                   = var.github_runner_memory

  container_definitions = jsonencode([
    {
      name  = "github-runner",
      image = "${aws_ecr_repository.runner_ecr.repository_url}:${var.github_runner_tag}",

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group  = aws_cloudwatch_log_group.ecs_github_runner.id,
          awslogs-region = var.aws_region,
          awslogs-stream-prefix : "run",
        }
      },
      environment = [],
      essential   = true,
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}


# IAM roles and policies

resource "aws_iam_role" "task_execution_github_runner" {
  name        = "TaskExecutionGithubRunnerRole"
  description = "Role for executing the Github runner (task execution role)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "task_execution_github_runner" {
  name = "TaskExecutionGithubRunnerPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # allow to pull images from ECR
      {
        Sid    = "ecr"
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ],
        Resource = ["*"],
      },
      # allow to write logs on CloudWatch
      {
        Sid    = "cloudwatch"
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = ["*"],
      },
      # allow kms, required for pulling images from ecr
      {
        Sid    = "kms",
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt",
        ],
        Resource = ["*"],
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  policy_arn = aws_iam_policy.task_execution_github_runner.arn
  role       = aws_iam_role.task_execution_github_runner.name
}

resource "aws_iam_role" "task_github_runner" {
  name        = "TaskGithubRunnerRole"
  description = "Role of the Github runner (task role)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_attachment" {
  count = length(var.iam_policy_arns)

  policy_arn = var.iam_policy_arns[count.index]
  role       = aws_iam_role.task_github_runner.name
}


# Security group

resource "aws_security_group" "github_runner" {
  name        = var.task_name
  description = "Security group for the Github runner"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "github_runner_rule" {
  for_each = {
    for rule in var.security_group_rules : rule.name => rule
  }

  type              = each.value.type
  description       = each.value.name
  security_group_id = aws_security_group.github_runner.id
  from_port         = 0
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}

# needed to allow Github to create the Runner
resource "aws_security_group_rule" "github_runner_to_internet" {
  type              = "egress"
  description       = "Internet access"
  security_group_id = aws_security_group.github_runner.id
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}


# Role for federating Github access for running the ECS task of the runner

# oidc federation must be already configured in aws
data "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_iac" {
  name        = "GitHubActionIACRole"
  description = "Role for invoking the TASK, assumed by GitHub with federated oidc credentials."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "Federated" : data.aws_iam_openid_connect_provider.github_oidc.arn,
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repository}:*"
          },
          "ForAllValues:StringEquals" = {
            "token.actions.githubusercontent.com:iss" : "https://token.actions.githubusercontent.com",
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "run_github_runner_ecs_task" {
  name        = "RunGithubRunnerEcsTask"
  description = "Policy for running the GitHub runner in ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # allow to run task for provisioning Github runner
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
        ],
        Resource = [aws_ecs_task_definition.github_runner_def.arn],
      },
      # allow to stopping task for cleaning up after Github action
      {
        Effect = "Allow",
        Action = [
          "ecs:StopTask",
        ],
        Resource = ["arn:aws:ecs:eu-south-1:${data.aws_caller_identity.current.id}:task/${var.ecs_cluster_name}/*"],
      },
      # the role needs to be passed to the task role and to the task execution role
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole",
        ],
        Resource = [
          aws_iam_role.task_github_runner.arn,
          aws_iam_role.task_execution_github_runner.arn,
        ],
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_iac" {
  role       = aws_iam_role.github_iac.name
  policy_arn = aws_iam_policy.run_github_runner_ecs_task.arn
}
