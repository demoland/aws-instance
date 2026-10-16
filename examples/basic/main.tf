module "instance" {
  source = "../.."

  region    = var.region
  name      = var.name
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  instance_type               = var.instance_type
  ingress_cidr_blocks         = var.ingress_cidr_blocks
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  tags                        = var.tags
}
