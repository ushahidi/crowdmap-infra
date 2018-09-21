resource "aws_iam_group" "ci" {
  name = "${data.null_data_source.env_constants.outputs.iam_ci_group_name}"
  path = "${data.null_data_source.env_constants.outputs.iam_groups_path}"
}
