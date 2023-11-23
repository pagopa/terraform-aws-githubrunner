
output "subnet_id" {
  value = aws_subnet.main.id
}

output "security_group_id" {
  value = module.aws_githubrunner.security_group_id
}
