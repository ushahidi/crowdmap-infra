terragrunt = {
  terraform {
    source = "../../../stacks//client-s3"
  }
  dependencies {
    paths = [ "../iam" ]
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}
