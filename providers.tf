terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = "Daniel Fedick"
      Purpose     = "Demoland Playground"
      Terraform   = true
      Environment = "development"
      DoNotDelete = true
      Name        = "Demoland"
      Type        = "Demoland Vault"
    }
  }

}
