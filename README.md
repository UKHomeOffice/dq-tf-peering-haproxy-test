# dq-tf-peering-haproxy

This Terraform module has one private subnet and deploys an EC2 instance, S3 bucket and IAM policies.

## Content overview

This repo controls the deployment of an application module.

It consists of the following core elements:

### main.tf

Describe the private subnet used by this module.

### data.tf

Describe data lookup for the EC2 AMI.

### instance.tf

This file contain the EC2 instance long with its Security Group allowing all type of traffic from dedicated networks.

### s3.tf

This file describe the following
- Create an S3 bucket with encryption, versioning and logging.
- Set up IAM policy for the bucket
- Create a role for the EC2 instance
- Policy and instance profile attachments
- VPC S3 endpoint

### output.tf

Various data outputs for other modules/consumers.

### variable.tf

Input data for resources within this repo.

### tests/haproxy_test.py

Code and resource tester with mock data. It can be expanded by adding further definitions to the unit.

## User guide

### Prepare your local environment

This project currently depends on:

* drone v0.5+dev
* terraform v0.11.1+
* terragrunt v0.13.21+
* python v3.6.3+

Please ensure that you have the correct versions installed (it is not currently tested against the latest version of Drone)

### How to run/deploy

To run tests using the [tf testsuite](https://github.com/UKHomeOffice/dq-tf-testsuite):
```shell
drone exec --repo.trusted
```
To launch:
```shell
terragrunt plan
terragrunt apply
```

## FAQs

### The remote state isn't updating, what do I do?

If the CI process appears to be stuck with a stale `tf state` then run the following command to force a refresh:

```
terragrunt refresh
```
If the CI process is still failing after a refresh look for errors about items no longer available in AWS - say something that was deleted manually via the AWS console or CLI.
To explicitly delete the stale resource from TF state use the following command below. *Note:*```terragrunt state rm``` will not delete the resource from AWS it will unlink it from state only.

```shell
terragrunt state rm aws_resource_name
```
