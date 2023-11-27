locals {
  ecs_cluster_name = "ghrunner-cluster"
}

module "aws_githubrunner" {
  source = "../.."

  task_name          = "ghrunner"
  github_runner_tag  = "1.0"
  ecs_cluster_name   = local.ecs_cluster_name
  ecs_create_cluster = true
  vpc_id             = module.vpc.vpc_id
  github_repository  = "pagopa/terraform-aws-githubrunner"
}
