
output "security_group_id" {
  value = aws_security_group.github_runner.id
}

output "github_iam_role_arn" {
  value = aws_iam_role.githubiac.arn
}
