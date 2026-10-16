variable "region" {
  type        = string
  description = "AWS region passed to the module."
  default     = "us-east-2"
}

variable "name" {
  type        = string
  description = "Name tag for the example instance."
  default     = "example-aws-instance"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID. No-code and this example both take the network as input instead of reading another workspace."
}

variable "subnet_id" {
  type        = string
  description = "Existing subnet ID. Use a public subnet when the instance should receive a public IP."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.medium"
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to reach TCP ports 22, 8080, and 8443. Example: [\"203.0.113.4/32\"]."
  default     = []
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP with the instance."
  default     = true
}

variable "key_name" {
  type        = string
  description = "Optional existing EC2 key pair name."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Extra tags merged into resources the module creates. The module adds a Name tag."
  default = {
    Environment = "example"
    ManagedBy   = "terraform"
  }
}
