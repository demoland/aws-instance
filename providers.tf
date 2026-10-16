# No-code workspaces apply this module as root configuration, so the AWS
# provider is configured here. Source and version live only in required_providers.
# Credentials, shared-config profiles, and assume_role are intentionally omitted;
# the workspace supplies them through a variable set or dynamic credentials.
provider "aws" {
  region = var.region
}
