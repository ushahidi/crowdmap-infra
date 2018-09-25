resource "aws_acm_certificate" "cert_lb" {
  domain_name = "*.${data.null_data_source.env_constants.outputs.env_fqdn}"
  subject_alternative_names = [
    "${data.null_data_source.env_constants.outputs.env_fqdn}",
    "*.${data.null_data_source.env_constants.outputs.env_fqdn}",
    "${data.null_data_source.env_constants.outputs.env_services_fqdn}",
    "*.${data.null_data_source.env_constants.outputs.env_services_fqdn}"
  ]
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_lb_validation_0" {
  name = "${aws_acm_certificate.cert_lb.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.cert_lb.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert_lb.domain_validation_options.0.resource_record_value}"]
  ttl = 60
}

resource "aws_route53_record" "cert_lb_validation_1" {
  name = "${aws_acm_certificate.cert_lb.domain_validation_options.1.resource_record_name}"
  type = "${aws_acm_certificate.cert_lb.domain_validation_options.1.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert_lb.domain_validation_options.1.resource_record_value}"]
  ttl = 60
}

resource "aws_route53_record" "cert_lb_validation_2" {
  name = "${aws_acm_certificate.cert_lb.domain_validation_options.2.resource_record_name}"
  type = "${aws_acm_certificate.cert_lb.domain_validation_options.2.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert_lb.domain_validation_options.2.resource_record_value}"]
  ttl = 60
}

resource "aws_route53_record" "cert_lb_validation_3" {
  name = "${aws_acm_certificate.cert_lb.domain_validation_options.3.resource_record_name}"
  type = "${aws_acm_certificate.cert_lb.domain_validation_options.3.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert_lb.domain_validation_options.3.resource_record_value}"]
  ttl = 60
}

resource "aws_route53_record" "cert_lb_validation_4" {
  name = "${aws_acm_certificate.cert_lb.domain_validation_options.4.resource_record_name}"
  type = "${aws_acm_certificate.cert_lb.domain_validation_options.4.resource_record_type}"
  zone_id = "${data.aws_route53_zone.services.id}"  # this is in the services zone
  records = ["${aws_acm_certificate.cert_lb.domain_validation_options.4.resource_record_value}"]
  ttl = 60
}

resource "aws_route53_record" "cert_lb_validation_5" {
  name = "${aws_acm_certificate.cert_lb.domain_validation_options.5.resource_record_name}"
  type = "${aws_acm_certificate.cert_lb.domain_validation_options.5.resource_record_type}"
  zone_id = "${data.aws_route53_zone.services.id}"  # this is in the services zone
  records = ["${aws_acm_certificate.cert_lb.domain_validation_options.5.resource_record_value}"]
  ttl = 60
}


resource "aws_acm_certificate_validation" "cert_lb" {
  certificate_arn = "${aws_acm_certificate.cert_lb.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.cert_lb_validation_0.fqdn}",
    "${aws_route53_record.cert_lb_validation_1.fqdn}",
    "${aws_route53_record.cert_lb_validation_2.fqdn}",
    "${aws_route53_record.cert_lb_validation_3.fqdn}",
    "${aws_route53_record.cert_lb_validation_4.fqdn}",
    "${aws_route53_record.cert_lb_validation_5.fqdn}"
  ]
}
