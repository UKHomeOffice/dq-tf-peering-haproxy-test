locals {
  naming_suffix = "haproxy-${var.naming_suffix}"
}

resource "aws_subnet" "haproxy_subnet" {
  vpc_id                  = var.peeringvpc_id
  cidr_block              = var.haproxy_subnet_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = var.az

  tags = {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "haproxy_subnet" {
  subnet_id      = aws_subnet.haproxy_subnet.id
  route_table_id = var.route_table_id
}

