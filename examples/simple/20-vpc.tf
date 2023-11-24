
resource "aws_vpc" "main" {
  cidr_block           = "172.32.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.32.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_vpc_endpoint" "ecr_endpoint_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface" # TODO cos'è?
  security_group_ids  = [aws_security_group.vpc_tls.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_endpoint_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface" # TODO cos'è?
  security_group_ids  = [aws_security_group.vpc_tls.id]
  private_dns_enabled = true
}

resource "aws_security_group" "vpc_tls" {
  name_prefix = "ghrunner_vpc_tls_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}
