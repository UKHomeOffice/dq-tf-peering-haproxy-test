## Creating Launch Configuration
resource "aws_launch_configuration" "peering-proxy" {
  image_id        = data.aws_ami.dq-peering-haproxy.id
  instance_type   = "t3a.micro"
  security_groups = [aws_security_group.instance.id]
  key_name        = var.key_name
  user_data       = <<-EOF
        #!/bin/bash

        set -e

        #log output from this user_data script
        exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

        echo "#!/bin/sh
        aws s3 cp s3://s3-dq-peering-haproxy-config-bucket-${var.namespace}/haproxy.cfg /etc/haproxy/haproxy.cfg --region eu-west-2
        /etc/ssl/certs/make-dummy-cert /etc/ssl/certs/self-signed-cert
        sudo haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf \$(cat /var/run/haproxy.pid)
        " > /home/centos/gets3content.sh

        echo "#Start the cloud watch agent"
        /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -s -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

### Creating Security Group for EC2
resource "aws_security_group" "instance" {
  name = "sg-ec2-${local.naming_suffix}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.haproxy_subnet_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "peering-proxy" {
  launch_configuration      = aws_launch_configuration.peering-proxy.id
  min_size                  = 1
  max_size                  = 2
  load_balancers            = [aws_elb.peering-proxy.name]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = aws_subnet.haproxy_subnet.id

  tag {
    key                 = "Name"
    value               = "ec2-${local.naming_suffix}"
    propagate_at_launch = true
  }
}

## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "sg-elb-${local.naming_suffix}"
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

### Creating ELB
resource "aws_elb" "peering-proxy" {
  name                      = "elb-${local.naming_suffix}"
  security_groups           = [aws_security_group.elb.id]
  subnets                   = [aws_subnet.haproxy_subnet.id]
  availability_zones        = ["eu-west-2a"]
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
