terragrunt = {
  terraform {
    source = "../../..//stacks/iam"
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}
