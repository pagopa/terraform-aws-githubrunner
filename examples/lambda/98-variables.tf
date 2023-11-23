
variable "aws_region" {
  type        = string
  description = "AWS region to create resources"
  default     = "eu-south-1"
}

variable "app_name" {
  type        = string
  description = "App name."
  default     = "ca"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment"
}

variable "env_short" {
  type        = string
  default     = "d"
  description = "Evnironment short."
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}
