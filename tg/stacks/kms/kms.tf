# default encryption key for the environment
resource "aws_kms_key" "env_default" {
  description = "${var.product}-${var.environment}-default"
  is_enabled = true
  enable_key_rotation = true
  tags {
    ush-environment = "${var.environment}"
    ush-product = "${var.product}"
  }
}

resource "aws_kms_alias" "env_default_alias" {
  name          = "alias/${var.product}-${var.environment}-default"
  target_key_id = "${aws_kms_key.env_default.key_id}"
}
