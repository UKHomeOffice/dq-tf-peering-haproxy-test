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

resource "aws_security_group" "instance" {
  vpc_id = var.peeringvpc_id

  tags = {
    Name = "sg-${local.naming_suffix}"
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = var.SGCIDRs
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
