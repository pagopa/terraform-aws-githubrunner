locals {
  project = format("%s-%s", var.app_name, var.env_short)
}

variable "aws_region" {
  type        = string
  description = "AWS region to create resources. Default Milan"
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

variable "ecs_logs_retention_days" {
  type        = number
  description = "ECS log group retention in days"
  default     = 5
}

# TODO how to manage tag?
variable "github_runner_tag" {
  type        = string
  description = "Image tag of the Github runner"
}

variable "github_runner_cpu" {
  type        = number
  description = "CPU assigned to the Github runner on ECS"
  default     = 2048
}

variable "github_runner_memory" {
  type        = number
  description = "Memory assigned to the Github runner on ECS"
  default     = 4096
}

variable "vpc_ids" {
  type        = set(string)
  description = "List of ids of VPCs that the runner needs to access"
  default     = []
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster to create. If not provided, cluster is not created."
  default     = ""
}

variable "security_group_vpc_id" {
  type        = string
  description = "ID of the  TBD"
}

variable "security_group_rules" {
  type = list(object({
    name        = string
    type        = string
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
  default = []
}

variable "iam_policy_arns" {
  type    = list(string)
  default = []
}

variable "github_repository" {
  type        = string
  description = "GitHub repository of the pipeline that will use the runner"
}
