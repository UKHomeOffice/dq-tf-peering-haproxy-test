

## Creating AutoScaling Group
resource "aws_autoscaling_group" "peering-proxy" {
  launch_configuration      = aws_launch_configuration.peering-proxy.id
  min_size                  = 1
  max_size                  = 2
  load_balancers            = [aws_elb.peering-proxy.name]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.haproxy_subnet.id]

  tag {
    key                 = "Name"
    value               = "ec2-${local.naming_suffix}"
    propagate_at_launch = true
  }
}
