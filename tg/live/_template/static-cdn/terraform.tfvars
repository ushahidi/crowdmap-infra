terragrunt = {
  terraform {
    source = "../../../stacks//static-cdn"
  }
  dependencies {
    paths = [ "../iam", "../static-s3", "../acm-certs" ]
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}
