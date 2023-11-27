
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  name                  = "${var.app_name}-vpc"
  cidr                  = "172.32.0.0/16"
  azs                   = var.availability_zones
  private_subnets       = ["172.32.0.0/24"]
  private_subnet_suffix = "private"
  public_subnets        = ["172.32.1.0/24"]
  public_subnet_suffix  = "public"

  enable_nat_gateway = true

  enable_dns_hostnames          = true
  enable_dns_support            = true
  map_public_ip_on_launch       = true
  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table    = false

}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "vpc_tls" {
  name_prefix = "ghrunner_vpc_tls_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.2.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "s3-vpc-endpoint" }
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      # policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]
      tags               = { Name = "logs-endpoint" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      # policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]

      tags = { Name = "ecr.api-endpoint" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      # policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      security_group_ids = [aws_security_group.vpc_tls.id]
      tags               = { Name = "ecr.dkr-endpoint" }
    }
  }

}
