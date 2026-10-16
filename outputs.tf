output "region" {
  description = "AWS region configured for this module."
  value       = var.region
}

output "instance_ids" {
  description = "IDs of the EC2 instances."
  value       = aws_instance.generic_instance[*].id
}

output "instance_arns" {
  description = "ARNs of the EC2 instances."
  value       = aws_instance.generic_instance[*].arn
}

output "instance_names" {
  description = "Name tags applied to the EC2 instances."
  value       = [for instance in aws_instance.generic_instance : instance.tags["Name"]]
}

output "public_ips" {
  description = "Public IP addresses of the EC2 instances. Entries are empty when an instance has no public IP."
  value       = aws_instance.generic_instance[*].public_ip
}

output "private_ips" {
  description = "Private IP addresses of the EC2 instances."
  value       = aws_instance.generic_instance[*].private_ip
}

output "public_dns" {
  description = "Public DNS names of the EC2 instances."
  value       = aws_instance.generic_instance[*].public_dns
}

output "private_dns" {
  description = "Private DNS names of the EC2 instances."
  value       = aws_instance.generic_instance[*].private_dns
}

output "availability_zones" {
  description = "Availability zones of the EC2 instances."
  value       = aws_instance.generic_instance[*].availability_zone
}

output "ami_id" {
  description = "AMI ID used to launch the instances."
  value       = local.ami_id
}

output "ami_architecture" {
  description = "CPU architecture used for AMI lookup when ami_id is null. Still reported when ami_id is set."
  value       = local.ami_architecture
}

output "subnet_id" {
  description = "Subnet ID where the instances are launched."
  value       = var.subnet_id
}

output "vpc_id" {
  description = "VPC ID passed to this module."
  value       = var.vpc_id
}

output "security_group_id" {
  description = "ID of the security group created for the instances. Null when create_security_group is false."
  value       = try(aws_security_group.ssh_sg[0].id, null)
}

output "key_name" {
  description = "EC2 key pair name associated with the instances. Null when no key is configured."
  value       = local.key_name
}

output "iam_role_name" {
  description = "Name of the IAM role created for the instances. Null when create_iam_instance_profile is false."
  value       = try(aws_iam_role.generic_instance[0].name, null)
}

output "iam_role_arn" {
  description = "ARN of the IAM role created for the instances. Null when create_iam_instance_profile is false."
  value       = try(aws_iam_role.generic_instance[0].arn, null)
}

output "iam_instance_profile_name" {
  description = "IAM instance profile attached to the instances. Null when no profile is attached."
  value       = local.iam_instance_profile_name
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile created by this module. Null when create_iam_instance_profile is false."
  value       = try(aws_iam_instance_profile.generic_instance[0].arn, null)
}
