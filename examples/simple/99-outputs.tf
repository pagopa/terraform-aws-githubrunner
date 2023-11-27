
output "subnet_ids" {
  value       = module.vpc.private_subnets
  description = "IDs of subnets managed"
}

output "security_group_id" {
  value = module.aws_githubrunner.security_group_id
}

output "github_iam_role_arn" {
  value       = module.aws_githubrunner.github_iam_role_arn
  description = "ARN of the IAM role federated for invoking the runner from a GitHub action"
}

output "ecr_repository_url" {
  value       = module.aws_githubrunner.ecr_repository_url
  description = "URL of the ECR repository of the GitHub runner"
}

output "ecs_task_definition_family" {
  value       = module.aws_githubrunner.ecs_task_definition_family
  description = "ECS task of the runner"
}

output "ecs_task_definition_arn" {
  value       = module.aws_githubrunner.ecs_task_definition_arn
  description = "ECS task of the runner"
}

output "ecs_cluster" {
  value       = local.ecs_cluster_name
  description = "ECS task of the runner"
}
