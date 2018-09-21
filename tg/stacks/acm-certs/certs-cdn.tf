provider "aws" {
	# provider bound to us-east-1 , where the cloudfront ACM certificates should be
	alias = "east_1"
	region = "us-east-1"
}

resource "aws_acm_certificate" "cert_cdn" {
  domain_name = "*.${data.null_data_source.env_constants.outputs.env_fqdn}"
  validation_method = "DNS"
  provider = "aws.east_1"
}

resource "aws_route53_record" "cert_cdn_validation" {
  name = "${aws_acm_certificate.cert_cdn.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.cert_cdn.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert_cdn.domain_validation_options.0.resource_record_value}"]
  ttl = 60
  provider = "aws.east_1"
}

resource "aws_acm_certificate_validation" "cert_cdn" {
  certificate_arn = "${aws_acm_certificate.cert_cdn.arn}"
  validation_record_fqdns = [ "${aws_route53_record.cert_cdn_validation.fqdn}" ]
  provider = "aws.east_1"
}
