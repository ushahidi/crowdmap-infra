terragrunt = {
  terraform {
    source = "../../../stacks//static-s3"
  }
  dependencies {
    paths = [ "../iam" ]
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}
