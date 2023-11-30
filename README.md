# terraform-aws-githubrunner

Terraform module for provisioning a GitHub runner definition as ECS task definition.
The task can be executed with visibility in a VPC via dedicated security group.

This module will create:

- ECS task definition for the runner
- Optionally, ECS cluster in which to run the task
- ECR repository for the runner image
- Log group in CloudWatch for monitoring runner logs
- Role for the runner with any number of policies passed as vars
- Security group in a VPC specificied
- Role for federated authentication for GitHub to run the task as runner

**NOTE**: the VPC in which to run the task must have a NAT Gateway configured.

## Prerequisites

- AWS account
- GitHub repo
- Identity provider configured in AWS for federated authentication with GitHub ([docs here](https://aws.amazon.com/it/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)).
- **VPC with a NAT Gateway**. This is required because because the runner needs to reach GitHub for
processing registration.

## Examples

See the [examples](examples/) folder for same examples of usage of this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs_github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.ecs_cluster_capacity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_task_definition.github_runner_def](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.run_github_runner_ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.task_execution_github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_iac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_execution_github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.github_iac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.github_runner_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.github_runner_to_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_openid_connect_provider.github_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources | `string` | `"eu-south-1"` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS cluster in which to run the task. Mandatory if 'ecs\_create\_cluster' is false | `string` | `"ghrunner-cluster"` | no |
| <a name="input_ecs_create_cluster"></a> [ecs\_create\_cluster](#input\_ecs\_create\_cluster) | Whether to create ECS cluster in which to run the GitHub runner as task | `bool` | `true` | no |
| <a name="input_ecs_logs_retention_days"></a> [ecs\_logs\_retention\_days](#input\_ecs\_logs\_retention\_days) | ECS log group retention in days | `number` | `5` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | GitHub repository of the pipeline that will use the runner | `string` | n/a | yes |
| <a name="input_github_runner_cpu"></a> [github\_runner\_cpu](#input\_github\_runner\_cpu) | CPU assigned to the Github runner on ECS | `number` | `2048` | no |
| <a name="input_github_runner_image"></a> [github\_runner\_image](#input\_github\_runner\_image) | Image of the Github runner | `string` | `"ghcr.io/pagopa/github-self-hosted-runner-aws:v1.1.0"` | no |
| <a name="input_github_runner_memory"></a> [github\_runner\_memory](#input\_github\_runner\_memory) | Memory assigned to the Github runner on ECS | `number` | `4096` | no |
| <a name="input_iam_policy_arns"></a> [iam\_policy\_arns](#input\_iam\_policy\_arns) | ARNs of policies to grant to the runner | `list(string)` | `[]` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Rules to apply to the runner security group | <pre>list(object({<br>    name        = string<br>    type        = string<br>    to_port     = number<br>    protocol    = string<br>    cidr_blocks = string<br>  }))</pre> | `[]` | no |
| <a name="input_task_name"></a> [task\_name](#input\_task\_name) | Name of the ECS task definition of the GitHub runner | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC that the runner will be able to access | `string` | n/a | yes |
| <a name="input_vpc_ids"></a> [vpc\_ids](#input\_vpc\_ids) | List of ids of VPCs that the runner needs to access | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | ARN of the ECS task of the runner |
| <a name="output_ecs_task_definition_family"></a> [ecs\_task\_definition\_family](#output\_ecs\_task\_definition\_family) | Family of the ECS task of the runner |
| <a name="output_github_iam_role_arn"></a> [github\_iam\_role\_arn](#output\_github\_iam\_role\_arn) | ARN of the IAM role federated for invoking the runner from a GitHub action |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group for the input VPC |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Name of the security group for the input VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
