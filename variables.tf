variable "region" {
  type        = string
  description = "AWS region for the provider configuration and every resource this module creates. Credentials are not set in the module; the workspace must supply them."
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-\\d+$", var.region))
    error_message = "region must be an AWS region code such as us-east-2."
  }
}

variable "name" {
  type        = string
  description = "Name tag. With one instance the Name tag is this value. With more than one instance the Name tags are name-0, name-1, and so on. Also used as the name prefix for the security group, IAM role, and optional key pair."
  default     = "aws-instance"

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 32 && can(regex("^[A-Za-z0-9][A-Za-z0-9_.-]*$", var.name))
    error_message = "name must be 1-32 characters, start with a letter or number, and contain only letters, numbers, dots, underscores, and hyphens."
  }
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to launch."
  default     = 1

  validation {
    condition     = var.instance_count >= 0 && var.instance_count <= 20 && floor(var.instance_count) == var.instance_count
    error_message = "instance_count must be a whole number from 0 through 20."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type, for example t3.medium. When ami_architecture is auto, Graviton families select an arm64 AMI and other families select amd64."
  default     = "t3.medium"

  validation {
    condition     = can(regex("^[a-z0-9-]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "instance_type must look like t3.medium."
  }
}

variable "ami_id" {
  type        = string
  description = "AMI ID to launch. Leave null to look up the most recent AMI matching ami_name_filter owned by ami_owners."
  default     = null

  validation {
    condition     = var.ami_id == null || can(regex("^ami-[0-9a-f]{8,17}$", var.ami_id))
    error_message = "ami_id must be null or an AMI id such as ami-0abc123def4567890."
  }
}

variable "ami_name_filter" {
  type        = string
  description = "Name filter used when ami_id is null. The token {arch} is replaced with amd64 or arm64. Wildcards are allowed."
  default     = "hc-base-ubuntu-2404-{arch}-*"

  validation {
    condition     = length(trimspace(var.ami_name_filter)) > 0
    error_message = "ami_name_filter must not be empty."
  }
}

variable "ami_owners" {
  type        = list(string)
  description = "AWS account IDs, or the aliases self, amazon, or aws-marketplace, that own the AMI used when ami_id is null. The default is the account that publishes hc-base-ubuntu-2404 images."
  default     = ["888995627335"]

  validation {
    condition = (
      length(var.ami_owners) > 0 &&
      alltrue([
        for owner in var.ami_owners : can(regex("^(\\d{12}|self|amazon|aws-marketplace)$", owner))
      ])
    )
    error_message = "ami_owners must contain at least one 12-digit account ID or one of: self, amazon, aws-marketplace."
  }
}

variable "ami_architecture" {
  type        = string
  description = "CPU architecture for AMI lookup: auto (infer from instance_type), amd64, or arm64. Ignored when ami_id is set."
  default     = "auto"

  validation {
    condition     = contains(["auto", "amd64", "arm64"], var.ami_architecture)
    error_message = "ami_architecture must be auto, amd64, or arm64."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group is created. Required even when create_security_group is false so the module stays explicit about placement."

  validation {
    condition     = can(regex("^vpc-([0-9a-f]{8}|[0-9a-f]{17})$", var.vpc_id))
    error_message = "vpc_id must be a VPC id such as vpc-0123456789abcdef0."
  }
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the instances are launched. Use a public subnet when associate_public_ip_address is true."

  validation {
    condition     = can(regex("^subnet-([0-9a-f]{8}|[0-9a-f]{17})$", var.subnet_id))
    error_message = "subnet_id must be a subnet id such as subnet-0123456789abcdef0."
  }
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with each instance. Set false for private subnets."
  default     = true
}

variable "enable_monitoring" {
  type        = bool
  description = "Enable detailed CloudWatch monitoring on each instance."
  default     = true
}

variable "key_name" {
  type        = string
  description = "Name of an existing EC2 key pair. Leave null to launch without a key. When public_key is set, this name is used for the created key pair, or name is used if this is null."
  default     = null

  validation {
    condition     = var.key_name == null || can(regex("^[A-Za-z0-9+=,.@_-]{1,255}$", var.key_name))
    error_message = "key_name must be null or a valid EC2 key pair name."
  }
}

variable "public_key" {
  type        = string
  description = "OpenSSH public key material. When set, the module creates an EC2 key pair and associates it with the instances. Sensitive."
  default     = null
  sensitive   = true

  validation {
    condition     = var.public_key == null || can(regex("^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp(256|384|521)) ", var.public_key))
    error_message = "public_key must be null or an OpenSSH public key (ssh-rsa, ssh-ed25519, or ecdsa-sha2-nistp*)."
  }
}

variable "volume_size" {
  type        = number
  description = "Root volume size in GiB."
  default     = 50

  validation {
    condition     = var.volume_size >= 1 && var.volume_size <= 16384 && floor(var.volume_size) == var.volume_size
    error_message = "volume_size must be a whole number of GiB from 1 through 16384."
  }
}

variable "volume_type" {
  type        = string
  description = "Root EBS volume type. Leave null to keep the AMI default."
  default     = null

  validation {
    condition     = var.volume_type == null || contains(["gp2", "gp3", "io1", "io2", "standard", "sc1", "st1"], var.volume_type)
    error_message = "volume_type must be null or one of: gp2, gp3, io1, io2, standard, sc1, st1."
  }
}

variable "volume_encrypted" {
  type        = bool
  description = "Encrypt the root volume. Leave null to accept the AMI and account default. Setting kms_key_id forces encryption on."
  default     = null
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID, ARN, or alias used to encrypt the root volume. Leave null to use the account default key when encryption is enabled."
  default     = null

  validation {
    condition     = var.kms_key_id == null || length(trimspace(var.kms_key_id)) > 0
    error_message = "kms_key_id must be null or a non-empty key id, ARN, or alias."
  }
}

variable "root_volume_delete_on_termination" {
  type        = bool
  description = "Delete the root EBS volume when the instance is terminated."
  default     = true
}

variable "install_docker" {
  type        = bool
  description = "Install Docker Engine with cloud-init when user_data is null. The script expects a Debian or Ubuntu AMI such as the default hc-base-ubuntu-2404 image."
  default     = true
}

variable "user_data" {
  type        = string
  description = "Cloud-init user data. When set, this replaces the optional Docker install script."
  default     = null
}

variable "user_data_replace_on_change" {
  type        = bool
  description = "Recreate instances when user data changes."
  default     = false
}

variable "create_security_group" {
  type        = bool
  description = "Create a security group in vpc_id and attach it to the instances."
  default     = true
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "IPv4 CIDR blocks allowed to reach ingress_ports. Leave empty to create no ingress rules. Example: [\"203.0.113.4/32\"]."
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.ingress_cidr_blocks : can(cidrnetmask(cidr))
    ])
    error_message = "ingress_cidr_blocks must contain valid IPv4 CIDR blocks such as 10.0.0.0/8 or 203.0.113.4/32."
  }
}

variable "ingress_ports" {
  type        = list(number)
  description = "TCP ports opened from ingress_cidr_blocks. Defaults match the previous workshop rules for SSH, HTTP-alt, and HTTPS-alt."
  default     = [22, 8080, 8443]

  validation {
    condition = (
      length(var.ingress_ports) == length(distinct(var.ingress_ports)) &&
      alltrue([for port in var.ingress_ports : port >= 1 && port <= 65535 && floor(port) == port])
    )
    error_message = "ingress_ports must be unique whole numbers from 1 through 65535."
  }
}

variable "allow_all_egress" {
  type        = bool
  description = "Allow all outbound IPv4 and IPv6 traffic from the created security group. Has no effect when create_security_group is false."
  default     = true
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "Existing security group IDs to attach in addition to, or instead of, the security group created by this module."
  default     = []

  validation {
    condition = alltrue([
      for id in var.additional_security_group_ids : can(regex("^sg-([0-9a-f]{8}|[0-9a-f]{17})$", id))
    ])
    error_message = "additional_security_group_ids must be security group ids such as sg-0123456789abcdef0."
  }
}

variable "create_iam_instance_profile" {
  type        = bool
  description = "Create an IAM role and instance profile for the instances. The EC2 service principal can assume the role."
  default     = true
}

variable "iam_instance_profile_name" {
  type        = string
  description = "Name of an existing instance profile to attach when create_iam_instance_profile is false. Leave null to launch with no profile."
  default     = null

  validation {
    condition     = var.iam_instance_profile_name == null || can(regex("^[A-Za-z0-9+=,.@_-]{1,128}$", var.iam_instance_profile_name))
    error_message = "iam_instance_profile_name must be null or a valid IAM instance profile name."
  }
}

variable "enable_describe_instances" {
  type        = bool
  description = "Attach an IAM policy that allows ec2:DescribeInstances on all resources. Ignored when iam_policy_json is set. Used by HashiCorp stack auto-join."
  default     = true
}

variable "iam_policy_json" {
  type        = string
  description = "IAM policy document JSON attached to the instance role. When set, it replaces the ec2:DescribeInstances policy. Leave null to use enable_describe_instances."
  default     = null

  validation {
    condition     = var.iam_policy_json == null || can(jsondecode(var.iam_policy_json))
    error_message = "iam_policy_json must be null or a valid JSON policy document."
  }
}

variable "additional_iam_policy_arns" {
  type        = list(string)
  description = "Managed IAM policy ARNs attached to the instance role when create_iam_instance_profile is true."
  default     = []

  validation {
    condition = alltrue([
      for arn in var.additional_iam_policy_arns : can(regex("^arn:aws[a-zA-Z0-9-]*:iam::(aws|[0-9]{12}):policy/.+", arn))
    ])
    error_message = "additional_iam_policy_arns must be IAM policy ARNs."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every taggable resource. The module also sets a Name tag on each resource; that Name wins if this map contains a Name key."
  default     = {}
}
