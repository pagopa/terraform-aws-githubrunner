
module "aws_githubrunner" {
  source = "../.."

  task_name         = "ghrunner"
  github_runner_tag = "1.0"
  ecs_cluster_name  = "ghrunner-cluster"
  vpc_id            = aws_vpc.main.id
  iam_policy_arns   = [aws_iam_policy.invoke_lambda.arn]
  github_repository = "TBD"
}
