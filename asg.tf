

## Creating AutoScaling Group
resource "aws_autoscaling_group" "peering-proxy" {
  launch_configuration      = aws_launch_configuration.peering-proxy.id
  min_size                  = 1
  max_size                  = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.haproxy_subnet.id, aws_subnet.haproxy_subnet_2b.id]

  tag {
    key                 = "Name"
    value               = "ec2-${local.naming_suffix}"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_attachment" "peering-proxy" {
  for_each               = var.forwarding_config
  autoscaling_group_name = aws_autoscaling_group.peering-proxy.id
  alb_target_group_arn   = aws_lb_target_group.peering-proxy[each.key].arn
}
