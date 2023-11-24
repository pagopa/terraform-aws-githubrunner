
output "security_group_id" {
  value       = aws_security_group.github_runner.id
  description = "ID of the security group for the input VPC"
}

output "security_group_name" {
  value       = aws_security_group.github_runner.name
  description = "Name of the security group for the input VPC"
}

output "github_iam_role_arn" {
  value       = aws_iam_role.github_iac.arn
  description = "ARN of the IAM role federated for invoking the runner from a GitHub action"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.runner_ecr.repository_url
  description = "URL of the ECR repository of the GitHub runner"
}

output "ecs_task_definition_family" {
  value       = aws_ecs_task_definition.github_runner_def.family
  description = "Family of the ECS task of the runner"
}

output "ecs_task_definition_arn" {
  value       = aws_ecs_task_definition.github_runner_def.arn
  description = "ARN of the ECS task of the runner"
}
