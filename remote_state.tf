
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "osage"
    workspaces = {
      name = "aws-vpc"
    }
  }
}

# data "terraform_remote_state" "kms" {
#   backend = "remote"

#   config = {
#     organization = "osage"
#     workspaces = {
#       name = "aws-kms"
#     }
#   }
# }
