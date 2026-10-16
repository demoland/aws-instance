output "instance_ids" {
  description = "IDs of the example instances."
  value       = module.instance.instance_ids
}

output "public_ips" {
  description = "Public IP addresses of the example instances."
  value       = module.instance.public_ips
}

output "private_ips" {
  description = "Private IP addresses of the example instances."
  value       = module.instance.private_ips
}

output "security_group_id" {
  description = "Security group created for the example instances."
  value       = module.instance.security_group_id
}

output "ami_id" {
  description = "AMI selected for the example instances."
  value       = module.instance.ami_id
}
