locals {
  environment = "development"
  region      = "us-east-2"
}

#If the ami_id variable is not set, then use the following data source to get the value
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
  ami_id          = var.ami_id != "" ? var.ami_id : data.aws_ami.rhel_8.image_id
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

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

EOF

}
