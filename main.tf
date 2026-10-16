locals {
  instance_family = split(".", var.instance_type)[0]

  # Graviton families use the arm64 AMI name token. Unknown families stay amd64;
  # set ami_architecture when a new Graviton family is not in this list.
  graviton_family = can(regex(
    "^(a1|t4g|c[6-9]g[dn]?|m[6-9]g[dn]?|r[6-9]g[dn]?|x[2-9]gd|i[4-9]g|im4gn|is4gen|g5g|hpc7g|mac2.*)$",
    local.instance_family,
  ))

  ami_architecture = (
    var.ami_architecture != "auto" ? var.ami_architecture :
    local.graviton_family ? "arm64" : "amd64"
  )

  ami_id = coalesce(var.ami_id, one(data.aws_ami.selected[*].id))

  key_name = try(aws_key_pair.this[0].key_name, var.key_name)

  security_group_ids = concat(
    aws_security_group.ssh_sg[*].id,
    var.additional_security_group_ids,
  )

  iam_instance_profile_name = try(
    aws_iam_instance_profile.generic_instance[0].name,
    var.iam_instance_profile_name,
  )

  iam_policy_json = (
    var.iam_policy_json != null ? var.iam_policy_json :
    var.enable_describe_instances ? jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "DescribeInstances"
          Effect   = "Allow"
          Action   = ["ec2:DescribeInstances"]
          Resource = "*"
        }
      ]
    }) :
    null
  )

  docker_user_data = file("${path.module}/templates/docker_user_data.sh")

  user_data = var.user_data != null ? var.user_data : (
    var.install_docker ? local.docker_user_data : null
  )

  instance_names = [
    for index in range(var.instance_count) :
    var.instance_count > 1 ? "${var.name}-${index}" : var.name
  ]
}

data "aws_ami" "selected" {
  count = var.ami_id == null ? 1 : 0

  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [replace(var.ami_name_filter, "{arch}", local.ami_architecture)]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_key_pair" "this" {
  count = var.public_key == null ? 0 : 1

  key_name   = coalesce(var.key_name, var.name)
  public_key = var.public_key

  tags = merge(var.tags, {
    Name = coalesce(var.key_name, var.name)
  })
}

resource "aws_instance" "generic_instance" {
  count = var.instance_count

  ami                         = local.ami_id
  instance_type               = var.instance_type
  key_name                    = local.key_name
  monitoring                  = var.enable_monitoring
  vpc_security_group_ids      = local.security_group_ids
  subnet_id                   = var.subnet_id
  iam_instance_profile        = local.iam_instance_profile_name
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = local.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    encrypted             = var.kms_key_id != null ? true : var.volume_encrypted
    kms_key_id            = var.kms_key_id
    delete_on_termination = var.root_volume_delete_on_termination

    tags = merge(var.tags, {
      Name = "${local.instance_names[count.index]}-root"
    })
  }

  tags = merge(var.tags, {
    Name = local.instance_names[count.index]
  })

  lifecycle {
    precondition {
      condition     = length(local.security_group_ids) > 0
      error_message = "Set additional_security_group_ids when create_security_group is false so each instance has a security group."
    }
  }
}

check "security_group_attachment" {
  assert {
    condition = (
      var.instance_count == 0 ||
      var.create_security_group ||
      length(var.additional_security_group_ids) > 0
    )
    error_message = "Set additional_security_group_ids when create_security_group is false."
  }
}
