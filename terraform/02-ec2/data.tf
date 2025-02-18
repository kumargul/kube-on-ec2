data "aws_caller_identity" "current" {}

data "aws_security_groups" "smc_provided_sg_ids" {
  tags = {
    Name = "AP2-INF-PROVIDER-SG-Provider-Services*"
  }
}

data "aws_secretsmanager_secret" "rootca" {
  name = "/dev/rootCA"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
