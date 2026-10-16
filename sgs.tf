resource "aws_security_group" "ssh_sg" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-ssh-"
  description = "Ingress for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.ingress_cidr_blocks) == 0 ? [] : var.ingress_ports

    content {
      description = "TCP ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.allow_all_egress ? [1] : []

    content {
      description      = "Allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
