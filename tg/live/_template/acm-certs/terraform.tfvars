terragrunt = {
  terraform {
    source = "../../..//stacks/acm-certs"
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}
