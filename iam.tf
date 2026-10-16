resource "aws_iam_role" "generic_instance" {
  count = var.create_iam_instance_profile ? 1 : 0

  name_prefix = "${var.name}-"
  description = "Instance role for ${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_iam_policy" "generic_instance" {
  count = var.create_iam_instance_profile && local.iam_policy_json != null ? 1 : 0

  name_prefix = "${var.name}-"
  description = "Instance policy for ${var.name}"
  policy      = local.iam_policy_json

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_iam_role_policy_attachment" "generic_instance" {
  count = var.create_iam_instance_profile && local.iam_policy_json != null ? 1 : 0

  role       = aws_iam_role.generic_instance[0].name
  policy_arn = aws_iam_policy.generic_instance[0].arn
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.create_iam_instance_profile ? toset(var.additional_iam_policy_arns) : toset([])

  role       = aws_iam_role.generic_instance[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "generic_instance" {
  count = var.create_iam_instance_profile ? 1 : 0

  name_prefix = "${var.name}-"
  role        = aws_iam_role.generic_instance[0].name

  tags = merge(var.tags, {
    Name = var.name
  })
}
