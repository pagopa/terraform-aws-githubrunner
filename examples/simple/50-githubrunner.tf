locals {
  ecs_cluster_name = "ghrunner-cluster"
}

module "aws_githubrunner" {
  source = "../.."

  task_name         = "ghrunner"
  github_runner_tag = "1.0"
  ecs_cluster_name  = local.ecs_cluster_name
  vpc_id            = aws_vpc.main.id
  github_repository = "https://github.com/pagopa/terraform-aws-githubrunner"
}
