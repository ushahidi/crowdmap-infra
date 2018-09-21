terragrunt = {
  terraform {
    source = "../../../stacks//lb"
  }
  dependencies {
    paths = [ "../iam", "../kms", "../acm-certs" ]
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}
