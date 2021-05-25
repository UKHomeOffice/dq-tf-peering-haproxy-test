resource "aws_kms_key" "haproxy_config_bucket_key" {
  description             = "This key is used to encrypt Haproxy config bucket objects"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "haproxy_config_bucket" {
  bucket = var.s3_bucket_name
  acl    = var.s3_bucket_acl

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.haproxy_config_bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = var.log_archive_s3_bucket
    target_prefix = "${var.service}-log/"
  }

  tags = {
    Name = "s3-${local.naming_suffix}"
  }
}

resource "aws_s3_bucket_policy" "haproxy_config_bucket" {
  bucket = var.s3_bucket_name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "HTTP",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY

}

resource "aws_s3_bucket_metric" "haproxy_config_bucket_logging" {
  bucket = var.s3_bucket_name
  name   = "haproxy_config_bucket_metric"
}

resource "aws_iam_policy" "haproxy_bucket_policy" {
  name = "haproxy_bucket_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.haproxy_config_bucket.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListObject"
      ],
      "Resource": ["${aws_s3_bucket.haproxy_config_bucket.arn}/*"]
    }
  ]
}
EOF

}

resource "aws_iam_policy" "haproxy_bucket_decrypt" {
  name = "haproxy_bucket_decrypt"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:Decrypt"
    ],
    "Resource": ["${aws_kms_key.haproxy_config_bucket_key.arn}"]
  }
}
EOF

}

resource "aws_iam_role" "haproxy_ec2_server_role" {
  name = "haproxy_ec2_server_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
                    "ec2.amazonaws.com",
                    "s3.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy_attachment" "attachs3_bucket_policy" {
  name       = "attachs3_bucket_policy"
  roles      = [aws_iam_role.haproxy_ec2_server_role.name]
  policy_arn = aws_iam_policy.haproxy_bucket_policy.arn
}

resource "aws_iam_policy_attachment" "attachs3_haproxy_bucket_decrypt" {
  name       = "attachs3_haproxy_bucket_decrypt"
  roles      = [aws_iam_role.haproxy_ec2_server_role.name]
  policy_arn = aws_iam_policy.haproxy_bucket_decrypt.arn
}

resource "aws_iam_instance_profile" "haproxy_server_instance_profile" {
  name = "haproxy_server_instance_profile"
  role = aws_iam_role.haproxy_ec2_server_role.name
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id          = var.peeringvpc_id
  route_table_ids = [var.route_table_id]
  service_name    = "com.amazonaws.eu-west-2.s3"
}
