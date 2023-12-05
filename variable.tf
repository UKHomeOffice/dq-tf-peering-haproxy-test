variable "account_id" {
  type = map(string)
  default = {
    "notprod" = "483846886818"
    "prod"    = "337779336338"
  }
}

variable "peeringvpc_id" {
}

variable "haproxy_private_ip" {
}

variable "haproxy_private_ip2" {
}

variable "haproxy_subnet_cidr_block" {
}

variable "log_archive_s3_bucket" {
}

variable "s3_bucket_name" {
}

variable "s3_bucket_acl" {
}

variable "route_table_id" {
}

variable "naming_suffix" {
  default     = false
  description = "Naming suffix for tags, value passed from dq-tf-apps"
}

variable "key_name" {
  default = "test_instance"
}

variable "s3_bucket_visibility" {
  default = "private"
}

variable "name_prefix" {
  default = "dq-peering-"
}

variable "service" {
  default     = "dq-peering-haproxy"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "az" {
  default = "eu-west-2a"
}

variable "namespace" {
}

variable "SGCIDRs" {
  description = "Ingress CIDR block for the HAProxy Security Group."
  type        = list(string)
}
