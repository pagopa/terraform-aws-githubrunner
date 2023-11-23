
resource "aws_vpc" "main" {
  cidr_block = "172.32.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "172.32.0.0/24"
}
