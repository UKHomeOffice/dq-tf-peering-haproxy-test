output "haproxy_subnet_id" {
  value = aws_subnet.haproxy_subnet.id
}

output "iam_roles" {
  value = [aws_iam_role.haproxy_ec2_server_role.id]
}

output "haproxy_config_bucket" {
  value = aws_s3_bucket.haproxy_config_bucket.id
}

output "haproxy_config_bucket_key" {
  value = aws_kms_key.haproxy_config_bucket_key.arn
}
