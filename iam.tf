resource "aws_iam_policy" "generic_instance" {
  name_prefix = "describe-instances-"
  path        = "/"
  description = "Policy to allow AWS auto join HashiStack servers in cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:DescribeInstances"]
        Effect   = "Allow"
        Sid      = "generic"
        Resource = "*"
      }
    ],
  })
}

# Create Role
resource "aws_iam_role" "generic_instance" {
  name_prefix = "sts_assume-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_policy_attachment" "generic_instance" {
  name       = "generic_instance"
  roles      = [aws_iam_role.generic_instance.name]
  policy_arn = aws_iam_policy.generic_instance.arn
}

resource "aws_iam_instance_profile" "generic_instance" {
  name_prefix = "generic_instance-"
  role        = aws_iam_role.generic_instance.name
}
