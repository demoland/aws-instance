locals {
  environment = "development"
  region      = "us-east-2"
}

data "aws_ami" "rhel_8" {
  owners      = ["self"]
  most_recent = true
  filter {
    name   = "name"
    values = ["packer-RHEL-8-stig-*"]
  }
}

locals {
  public_subnet_0 = element(data.terraform_remote_state.vpc.outputs.public_subnet_ids, 0)
  public_subnets  = data.terraform_remote_state.vpc.outputs.*.public_subnet_ids
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  my_ip           = var.my_ip
  cidr_block      = var.cidr_block
  ami_id          = data.aws_ami.rhel_8.image_id
  management_key  = "management"
  ssh_sg          = aws_security_group.ssh_sg.id
  instance_type   = var.instance_type
  volume_size     = var.volume_size
}

resource "aws_instance" "generic_instance" {
  count                       = 1
  ami                         = local.ami_id
  instance_type               = local.instance_type
  key_name                    = local.management_key
  monitoring                  = true
  vpc_security_group_ids      = [local.ssh_sg]
  subnet_id                   = local.public_subnet_0
  iam_instance_profile        = aws_iam_instance_profile.generic_instance.name
  associate_public_ip_address = true
  tags = {
    Name = "aws-instance-${count.index}",
  }

  root_block_device {
    volume_size = local.volume_size
  }

  user_data = <<EOF
#!/bin/bash
exec > /tmp/setup.log 2>&1

### Install Docker #############################################################
echo "SWEET"
echo "${aws_instance.generic_instance.public_ip}"

EOF

}
