resource "aws_s3_bucket" "client" {
  bucket = "${data.null_data_source.env_constants.outputs.client_bucket}"

  website {
    index_document = "index.html"
  }

  tags {
    ush-environment = "${var.environment}"
    ush-product = "${var.product}"
  }
}

# permissions for the ci user to update the bucket
resource "aws_iam_group_policy" "ci_s3_bucket" {
	name = "${var.product}-${var.environment}-client-ci-access"
	group = "${data.null_data_source.env_constants.outputs.iam_ci_group_name}"
	policy = <<EOP
{
	"Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.client.id}",
        "arn:aws:s3:::${aws_s3_bucket.client.id}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
EOP
}

output "client_bucket_name" { value = "${aws_s3_bucket.client.id}" }
