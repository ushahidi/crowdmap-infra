terragrunt = {
  remote_state {
    backend = "s3"
    config = {
      bucket = "ushahidi-terraform-states"
      key = "crowdmap-infra/${path_relative_to_include()}/terraform.tfstate"
      encrypt = true
      dynamodb_table = "ushahidi-terraform-states-lock"
      region = "us-east-1"
    }
  }

  terraform {
    extra_arguments "common_vars" {
      commands = ["${get_terraform_commands_that_need_vars()}"]
      required_var_files = [
        "${get_parent_tfvars_dir()}/common.tfvars",
      ],
      optional_var_files = [
        "${get_tfvars_dir()}/../env.tfvars"
      ]
    }
  }
}
