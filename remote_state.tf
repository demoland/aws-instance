
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "demo-land"
    workspaces = {
      name = "aws-vpc"
    }
  }
}

# data "terraform_remote_state" "kms" {
#   backend = "remote"

#   config = {
#     organization = "demo-land"
#     workspaces = {
#       name = "aws-kms"
#     }
#   }
# }
