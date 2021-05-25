
### Creating ELB
resource "aws_elb" "peering-proxy" {
  name            = "elb-${local.naming_suffix}"
  security_groups = [aws_security_group.elb.id]
  subnets         = [aws_subnet.haproxy_subnet.id]
  # availability_zones        = ["eu-west-2a"]
  cross_zone_load_balancing = false

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "TCP:5432"
  }

  listener {
    lb_port           = 5431
    lb_protocol       = "tcp"
    instance_port     = 5431
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 5432
    lb_protocol       = "tcp"
    instance_port     = 5432
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 8080
    lb_protocol       = "https"
    instance_port     = 8080
    instance_protocol = "https"
  }

  listener {
    lb_port           = 8081
    lb_protocol       = "https"
    instance_port     = 8081
    instance_protocol = "https"
  }

  listener {
    lb_port           = 8082
    lb_protocol       = "tcp"
    instance_port     = 8082
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 8083
    lb_protocol       = "https"
    instance_port     = 8083
    instance_protocol = "https"
  }

  listener {
    lb_port           = 8084
    lb_protocol       = "tcp"
    instance_port     = 8084
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 8085
    lb_protocol       = "https"
    instance_port     = 8085
    instance_protocol = "https"
  }

  listener {
    lb_port           = 8086
    lb_protocol       = "tcp"
    instance_port     = 8086
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 8087
    lb_protocol       = "tcp"
    instance_port     = 8087
    instance_protocol = "tcp"
  }

  tags = {
    Name = "elb-${local.naming_suffix}"
  }
}

## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "elb-sg-${local.naming_suffix}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [var.haproxy_subnet_cidr_block]
  }
  ingress {
    from_port   = 8080
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = var.SGCIDRs
  }
  ingress {
    from_port   = 5431
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.SGCIDRs
  }
}
