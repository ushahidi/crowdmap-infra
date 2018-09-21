terragrunt = {
  terraform {
    source = "../../..//stacks/web"
  }
  dependencies {
    paths = [ "../iam", "../kms", "../lb" ]
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}

instance_count = 1
