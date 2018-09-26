terragrunt = {
  terraform {
    source = "../../..//stacks/db"
  }
  dependencies {
    paths = [ "../iam", "../kms", "../alarms" ]
  }
  include {
    path = "${find_in_parent_folders()}"
  }
}

db_admin_username = "admin"
db_admin_password = "3DJ7oE9fcJE71GDedX1E"
