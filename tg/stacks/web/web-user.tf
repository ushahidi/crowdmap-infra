# iam user - use this one for all operations originated from web servers / app
resource "aws_iam_user" "web" {
  name = "${var.product}-${var.environment}-web"
}

resource "aws_iam_access_key" "web" {
  user = "${aws_iam_user.web.name}"
}

# iam user ses sending
resource "aws_iam_user_policy" "ses_send_email" {
	name = "ses-send-email"
	user = "${aws_iam_user.web.name}"
	policy = <<EOP
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ses:SendRawEmail",
            "Resource": "*"
        }
    ]
}
EOP
}

output "iam_api_username"     { value = "${var.product}-${var.environment}-web" }
output "iam_api_key_id"				{ value = "${aws_iam_access_key.web.id}" }
output "iam_api_secret_key"		{ value = "${aws_iam_access_key.web.secret}" }
output "iam_api_ses_smtp_password"  { value = "${aws_iam_access_key.web.ses_smtp_password}" }
