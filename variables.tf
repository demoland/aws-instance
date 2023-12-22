variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

variable "cidr_block" {
  default = "10.42.0.0/16"
}

variable "my_ip" {
  default = "x.x.x.x/32"
}

variable "instance_type" {
  description = "Description of the instance type"
  default     = "t3.medium"
}

variable "volume_size" {
  description = "Volume Size in GB"
  type        = number
  default     = 50
}

variable "management_pubkey" {
  description = "Management Public Key"
  sensitive   = true
  type        = string
}
