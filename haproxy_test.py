# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """

            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }

            module "haproxy-instance" {
              source = "./mymodule"

              providers = {
                aws = "aws"
              }
                haproxy_subnet_cidr_block = "1.2.3.0/24"
                peeringvpc_id          = "1234"
                haproxy_private_ip     = "1.2.3.4"
                haproxy_private_ip2    = "1.2.3.4"
                name_prefix            = "dq-"
                SGCIDRs                = ["1.2.3.0/24"]
                az                     = "foo"
                route_table_id         = "1234"
                s3_bucket_name         = "abcd"
                s3_bucket_acl          = "private"
                log_archive_s3_bucket  = "abcd"
                naming_suffix          = "peering-preprod-dq"
                namespace              = "notprod"
            }
        """
        self.runner = Runner(self.snippet)
        self.result = self.runner.result

    def test_name_peeringhaproxy(self):
        self.assertEqual(self.runner.get_value("module.haproxy-instance.aws_instance.peeringhaproxy", "tags"), {'Name': "ec2-haproxy-peering-preprod-dq"})

    def test_name_sg_haproxy(self):
        self.assertEqual(self.runner.get_value("module.haproxy-instance.aws_security_group.haproxy", "tags"), {'Name': "sg-haproxy-peering-preprod-dq"})

    def test_name_config_bucket_name(self):
        self.assertEqual(self.runner.get_value("module.haproxy-instance.aws_s3_bucket.haproxy_config_bucket", "tags"), {'Name': "s3-haproxy-peering-preprod-dq"})

if __name__ == '__main__':
    unittest.main()
