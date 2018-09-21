terragrunt = {
  terraform {
    source = "../../..//stacks/alarms"
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}
