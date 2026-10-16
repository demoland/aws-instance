# Basic example

Launches the instance module into an existing VPC and subnet.

The module configures the AWS provider itself (`region` only). Export AWS credentials in the environment, or run this example in a workspace whose variable set provides them. Do not put keys in this directory.

```bash
export AWS_REGION=us-east-2
terraform init
terraform apply \
  -var vpc_id=vpc-0123456789abcdef0 \
  -var subnet_id=subnet-0123456789abcdef0 \
  -var 'ingress_cidr_blocks=["203.0.113.4/32"]'
```

`vpc_id` and `subnet_id` have no defaults. `ingress_cidr_blocks` defaults to an empty list, so the security group has no inbound rules until you set it.
