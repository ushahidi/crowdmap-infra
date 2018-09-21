terragrunt = {
  terraform {
    source = "../../../stacks//client-cdn"
  }
  dependencies {
    paths = [ "../iam", "../client-s3", "../acm-certs" ]
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}
