locals {
  policies = [
    aws_iam_policy.control_plane.arn,
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
}

resource "aws_iam_role" "control_plane" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "testingGK-${var.environment}-controlPlane"
}

resource "aws_iam_role_policy_attachment" "control_plane" {
  count      = length(local.policies)
  role       = aws_iam_role.control_plane.name
  policy_arn = local.policies[count.index]
}

resource "aws_iam_instance_profile" "control_plane" {
  name = "testingGK-${var.environment}-controlPlane"
  role = aws_iam_role.control_plane.name
}

resource "aws_iam_policy" "control_plane" {
  name_prefix = "esb-toolbox-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:Get*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:DeleteTags",
          "ec2:CreateTags",
          "ec2:RebootInstances",
          "kms:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
    }]
  })
}
