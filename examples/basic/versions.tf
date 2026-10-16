terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }
}

# The module configures its own AWS provider from var.region so it can run as a
# no-code root module. This provider block documents the same region for anyone
# adding resources alongside the module. Credentials stay in the environment.
provider "aws" {
  region = var.region
}
