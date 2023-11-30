locals {
  ecs_cluster_name = "ghrunner-cluster"
}

resource "aws_iam_policy" "list_buckets" {
  name        = "ListBuckets"
  description = "Policy for listing s3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:List*",
        ],
        Resource = ["*"],
      },
    ]
  })
}

module "aws_githubrunner" {
  source = "../.."

  task_name          = "ghrunner"
  ecs_cluster_name   = local.ecs_cluster_name
  ecs_create_cluster = true
  vpc_id             = module.vpc.vpc_id
  github_repository  = "pagopa/terraform-aws-githubrunner"
  iam_policy_arns    = [aws_iam_policy.list_buckets.arn]
}
