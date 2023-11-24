# terraform-aws-runner: Simple example

Minimal simple example of module usage.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | =5.11.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_githubrunner"></a> [aws\_githubrunner](#module\_aws\_githubrunner) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.invoke_lambda](https://registry.terraform.io/providers/hashicorp/aws/5.11.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.11.0/docs/resources/iam_role) | resource |
| [aws_lambda_function.test_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/5.11.0/docs/resources/lambda_function) | resource |
| [aws_subnet.main](https://registry.terraform.io/providers/hashicorp/aws/5.11.0/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/5.11.0/docs/resources/vpc) | resource |
| [archive_file.lambda_package](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/5.11.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name. | `string` | `"ca"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources | `string` | `"eu-south-1"` | no |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Evnironment short. | `string` | `"d"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | `"dev"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
