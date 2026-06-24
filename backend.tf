terraform {
  required_version = "~> 1.15"
  backend "remote" {
    organization = "osage"
    workspaces {
      name = "aws-instance"
    }
  }
}
