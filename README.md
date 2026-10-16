# AWS instance module

Reusable root module that launches EC2 instances in an existing VPC and subnet, with a security group, an IAM instance profile, and an optional AMI lookup. It is written for [HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/no-code-provisioning/module-design) and Terraform Enterprise no-code provisioning, and for tag-based publishing to the private registry.

The module does not configure a backend or `cloud` block, and it does not read other workspaces. Callers pass `vpc_id` and `subnet_id`. The AWS provider source and version are declared only in `required_providers`. The provider block sets `region` from [`var.region`](#input_region) and does not set keys, a shared-config profile, or `assume_role`.

Only `vpc_id` and `subnet_id` are required. Every other input has a default.

## Usage

### No-code

After the module is published and no-code is enabled, open the private registry, select this module, and choose **Provision workspace**. Set `vpc_id` and `subnet_id`. Leave the other inputs at their defaults unless you need to change them.

Supply AWS credentials to the new workspace with a project or global variable set (environment variables or [dynamic provider credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials)). Do not commit credentials into this repository. The `region` input is the provider region; it overrides `AWS_REGION` from the environment.

### Private registry

```hcl
module "instance" {
  source  = "app.terraform.io/<ORGANIZATION>/instance/aws"
  version = "1.0.0"

  region    = "us-east-2"
  vpc_id    = "vpc-0123456789abcdef0"
  subnet_id = "subnet-0123456789abcdef0"

  ingress_cidr_blocks = ["203.0.113.4/32"]

  tags = {
    Environment = "development"
    Team        = "platform"
  }
}
```

Replace `<ORGANIZATION>` with the HCP Terraform organization that publishes the module. The previous workspace in this repo used organization `osage`.

Because this module configures the AWS provider, do not call it with `count`, `for_each`, or `depends_on`. Those meta-arguments cannot be combined with a module that contains a provider configuration.

### Local example

See [examples/basic](examples/basic). From that directory:

```bash
terraform init
terraform apply \
  -var vpc_id=vpc-0123456789abcdef0 \
  -var subnet_id=subnet-0123456789abcdef0 \
  -var 'ingress_cidr_blocks=["203.0.113.4/32"]'
```

## Publish to the private registry

Publish with Git tags, not from a branch. The registry ignores tags that are not semantic versions. `v1.0.0` and `1.0.0` are both valid; use the `v` prefix.

### 1. Rename the repository

Rename `aws-instance` to `terraform-aws-instance` before you publish. The private registry convention is `terraform-<PROVIDER>-<NAME>`, which here is provider `aws` and module name `instance`. The module address is:

```text
app.terraform.io/<ORGANIZATION>/instance/aws
```

This pull request does not rename the repository.

### 2. Tag a release

Tag the commit you want to publish (the merge commit of the module change, or a descendant of it):

```bash
git checkout main
git pull
git tag v1.0.0
git push origin v1.0.0
```

The repository must contain at least one semver tag before tag-based publishing will accept it. Later versions are the same operation: `git tag v1.1.0 && git push origin v1.1.0`. The registry imports new tags on its own. Deleting a Git tag does not delete the registry version.

### 3. Add the module

You need permission to manage the private registry, and the organization's GitHub connection must be in place. The VCS user needs admin access to the repository so the registry can create webhooks.

1. Sign in to HCP Terraform or Terraform Enterprise and open the organization that should own the module.
2. Go to **Registry**.
3. Choose **Module** from the **Publish** menu.
4. Select the GitHub VCS connection, then select `terraform-aws-instance`.
5. Set the publishing type to **Tag**. Leave **Module tag prefix** empty. Leave **Source directory** empty so the repository root is the module.
6. Set **Module name** to `instance` and **Provider name** to `aws`.
7. Enable **Add module to no-code provision allowlist**.
8. Click **Publish module** and wait until version `1.0.0` is listed.

No-code provisioning requires HCP Terraform Standard or Premium, or Terraform Enterprise.

### 4. Enable no-code and provision

Enabling the allowlist during publish makes the version no-code ready. If you skipped that checkbox, open the module, then **Manage module for organization**, and enable no-code provisioning. Pin version `1.0.0` if new tags should not become the no-code version automatically.

Then:

1. Create a project-scoped variable set (or a global one) with AWS credentials and assign it to the project where no-code workspaces are created. The module does not contain credentials.
2. In **Registry → Modules**, open this module and choose **Provision workspace**.
3. Enter `vpc_id` and `subnet_id`. Set `ingress_cidr_blocks` if the instance should accept inbound traffic. The default is no ingress.
4. Start the run. The workspace applies this module as its root configuration.

`docs/consul-k8s` is leftover workshop material (Minikube notes). It is not part of the module and is not a registry example.

## Upgrading from the workspace root

This repository used to be the root configuration for an HCP Terraform workspace. That state is not reusable as-is. Provision a new workspace from the published module instead of adopting the old state.

- The remote backend (`organization = osage`, workspace `aws-instance`) and the `terraform_remote_state` read of workspace `aws-vpc` are gone. Pass `vpc_id` and `subnet_id`.
- `management_pubkey`, `cidr_block`, and `my_ip` are gone. Use `public_key`, `key_name`, and `ingress_cidr_blocks`.
- Instances are no longer launched with key pair `management` unless you set `key_name` or `public_key`.
- Inbound ports 22, 8080, and 8443 are not opened until `ingress_cidr_blocks` is set. The old rules also allowed `0.0.0.0/0`.
- Hardcoded workshop tags and provider default tags are not applied. Pass them in `tags`. The module adds a `Name` tag.
- The security group uses a name prefix, and the IAM policy is attached with `aws_iam_role_policy_attachment` instead of the exclusive `aws_iam_policy_attachment`.
- `ami_id` uses `null`, not `""`, to mean "look up the AMI".
- The Terraform version constraint is `>= 1.5.0`. The AWS provider constraint is unchanged (`~> 6.28.0`).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.generic_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.generic_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.generic_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.generic_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.generic_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.ssh_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID where the instances are launched. Use a public subnet when associate\_public\_ip\_address is true. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the security group is created. Required even when create\_security\_group is false so the module stays explicit about placement. | `string` | n/a | yes |
| <a name="input_additional_iam_policy_arns"></a> [additional\_iam\_policy\_arns](#input\_additional\_iam\_policy\_arns) | Managed IAM policy ARNs attached to the instance role when create\_iam\_instance\_profile is true. | `list(string)` | `[]` | no |
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | Existing security group IDs to attach in addition to, or instead of, the security group created by this module. | `list(string)` | `[]` | no |
| <a name="input_allow_all_egress"></a> [allow\_all\_egress](#input\_allow\_all\_egress) | Allow all outbound IPv4 and IPv6 traffic from the created security group. Has no effect when create\_security\_group is false. | `bool` | `true` | no |
| <a name="input_ami_architecture"></a> [ami\_architecture](#input\_ami\_architecture) | CPU architecture for AMI lookup: auto (infer from instance\_type), amd64, or arm64. Ignored when ami\_id is set. | `string` | `"auto"` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID to launch. Leave null to look up the most recent AMI matching ami\_name\_filter owned by ami\_owners. | `string` | `null` | no |
| <a name="input_ami_name_filter"></a> [ami\_name\_filter](#input\_ami\_name\_filter) | Name filter used when ami\_id is null. The token {arch} is replaced with amd64 or arm64. Wildcards are allowed. | `string` | `"hc-base-ubuntu-2404-{arch}-*"` | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | AWS account IDs, or the aliases self, amazon, or aws-marketplace, that own the AMI used when ami\_id is null. The default is the account that publishes hc-base-ubuntu-2404 images. | `list(string)` | <pre>[<br/>  "888995627335"<br/>]</pre> | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Associate a public IP address with each instance. Set false for private subnets. | `bool` | `true` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | Create an IAM role and instance profile for the instances. The EC2 service principal can assume the role. | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create a security group in vpc\_id and attach it to the instances. | `bool` | `true` | no |
| <a name="input_enable_describe_instances"></a> [enable\_describe\_instances](#input\_enable\_describe\_instances) | Attach an IAM policy that allows ec2:DescribeInstances on all resources. Ignored when iam\_policy\_json is set. Used by HashiCorp stack auto-join. | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable detailed CloudWatch monitoring on each instance. | `bool` | `true` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | Name of an existing instance profile to attach when create\_iam\_instance\_profile is false. Leave null to launch with no profile. | `string` | `null` | no |
| <a name="input_iam_policy_json"></a> [iam\_policy\_json](#input\_iam\_policy\_json) | IAM policy document JSON attached to the instance role. When set, it replaces the ec2:DescribeInstances policy. Leave null to use enable\_describe\_instances. | `string` | `null` | no |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | IPv4 CIDR blocks allowed to reach ingress\_ports. Leave empty to create no ingress rules. Example: ["203.0.113.4/32"]. | `list(string)` | `[]` | no |
| <a name="input_ingress_ports"></a> [ingress\_ports](#input\_ingress\_ports) | TCP ports opened from ingress\_cidr\_blocks. Defaults match the previous workshop rules for SSH, HTTP-alt, and HTTPS-alt. | `list(number)` | <pre>[<br/>  22,<br/>  8080,<br/>  8443<br/>]</pre> | no |
| <a name="input_install_docker"></a> [install\_docker](#input\_install\_docker) | Install Docker Engine with cloud-init when user\_data is null. The script expects a Debian or Ubuntu AMI such as the default hc-base-ubuntu-2404 image. | `bool` | `true` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of EC2 instances to launch. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type, for example t3.medium. When ami\_architecture is auto, Graviton families select an arm64 AMI and other families select amd64. | `string` | `"t3.medium"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of an existing EC2 key pair. Leave null to launch without a key. When public\_key is set, this name is used for the created key pair, or name is used if this is null. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID, ARN, or alias used to encrypt the root volume. Leave null to use the account default key when encryption is enabled. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name tag. With one instance the Name tag is this value. With more than one instance the Name tags are name-0, name-1, and so on. Also used as the name prefix for the security group, IAM role, and optional key pair. | `string` | `"aws-instance"` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | OpenSSH public key material. When set, the module creates an EC2 key pair and associates it with the instances. Sensitive. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the provider configuration and every resource this module creates. Credentials are not set in the module; the workspace must supply them. | `string` | `"us-east-2"` | no |
| <a name="input_root_volume_delete_on_termination"></a> [root\_volume\_delete\_on\_termination](#input\_root\_volume\_delete\_on\_termination) | Delete the root EBS volume when the instance is terminated. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every taggable resource. The module also sets a Name tag on each resource; that Name wins if this map contains a Name key. | `map(string)` | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Cloud-init user data. When set, this replaces the optional Docker install script. | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | Recreate instances when user data changes. | `bool` | `false` | no |
| <a name="input_volume_encrypted"></a> [volume\_encrypted](#input\_volume\_encrypted) | Encrypt the root volume. Leave null to accept the AMI and account default. Setting kms\_key\_id forces encryption on. | `bool` | `null` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Root volume size in GiB. | `number` | `50` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Root EBS volume type. Leave null to keep the AMI default. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_architecture"></a> [ami\_architecture](#output\_ami\_architecture) | CPU architecture used for AMI lookup when ami\_id is null. Still reported when ami\_id is set. |
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI ID used to launch the instances. |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | Availability zones of the EC2 instances. |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | ARN of the IAM instance profile created by this module. Null when create\_iam\_instance\_profile is false. |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | IAM instance profile attached to the instances. Null when no profile is attached. |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role created for the instances. Null when create\_iam\_instance\_profile is false. |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role created for the instances. Null when create\_iam\_instance\_profile is false. |
| <a name="output_instance_arns"></a> [instance\_arns](#output\_instance\_arns) | ARNs of the EC2 instances. |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | IDs of the EC2 instances. |
| <a name="output_instance_names"></a> [instance\_names](#output\_instance\_names) | Name tags applied to the EC2 instances. |
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | EC2 key pair name associated with the instances. Null when no key is configured. |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | Private DNS names of the EC2 instances. |
| <a name="output_private_ips"></a> [private\_ips](#output\_private\_ips) | Private IP addresses of the EC2 instances. |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | Public DNS names of the EC2 instances. |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | Public IP addresses of the EC2 instances. Entries are empty when an instance has no public IP. |
| <a name="output_region"></a> [region](#output\_region) | AWS region configured for this module. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group created for the instances. Null when create\_security\_group is false. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Subnet ID where the instances are launched. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID passed to this module. |
<!-- END_TF_DOCS -->
