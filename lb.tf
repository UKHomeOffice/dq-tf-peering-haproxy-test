

variable "forwarding_config" {
  default = {
    5431 = "TCP"
    5432 = "TCP"
    8080 = "TCP"
    8081 = "TCP"
    8082 = "TCP"
    8083 = "TCP"
    8084 = "TCP"
    8085 = "TCP"
    8086 = "TCP"
    8087 = "TCP"
  }
}

## Security Group for ELB
resource "aws_security_group" "nlb" {
  name   = "nlb-sg-${local.naming_suffix}"
  vpc_id = var.peeringvpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [var.haproxy_subnet_cidr_block, var.haproxy_subnet_cidr_block_2b]
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

resource "aws_lb" "peering-proxy" {
  name                       = "nlb-${local.naming_suffix}"
  security_groups            = [aws_security_group.nlb.id]
  load_balancer_type         = "network"
  enable_deletion_protection = true

  subnet_mapping {
    subnet_id = aws_subnet.haproxy_subnet.id
    # private_ipv4_address  = var.haproxy_private_ip\
    # private_ipv4_address = "10.3.0.13"
  }

  subnet_mapping {
    subnet_id = aws_subnet.haproxy_subnet_2b.id
    # private_ipv4_address  = var.haproxy_private_ip\
    # private_ipv4_address = "10.3.1.13"
  }

  tags = {
    Name = "nlb-${local.naming_suffix}"
  }
}

resource "aws_lb_listener" "peering-proxy" {
  load_balancer_arn = aws_lb.peering-proxy.arn
  for_each          = var.forwarding_config
  port              = each.key
  protocol          = each.value
  default_action {
    target_group_arn = aws_lb_target_group.peering-proxy[each.key].arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "peering-proxy" {
  for_each             = var.forwarding_config
  name                 = "peering-proxy-tg-${each.key}"
  port                 = each.key
  protocol             = each.value
  vpc_id               = var.peeringvpc_id
  target_type          = "instance"
  deregistration_delay = 90
  health_check {
    interval            = 30
    port                = each.key
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Environment = "peering-proxy-tg-${each.key}"
  }
}

# resource "aws_lb_target_group_attachment" "peering-proxy" {
#   for_each         = var.forwarding_config
#   target_group_arn = aws_lb_target_group.peering-proxy[each.key].arn
#   port             = each.key
#   target_id        = lookup(var.tg_config, "target_id1")
# }
