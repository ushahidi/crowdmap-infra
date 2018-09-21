data "aws_acm_certificate" "lb" {
	domain = "*.${data.null_data_source.env_constants.outputs.env_fqdn}"
	statuses = ["ISSUED"]
	most_recent = true
}

# lb security groups
resource "aws_security_group" "lb" {
	name = "${data.null_data_source.env_constants.outputs.load_balancer_sg}"
	description = "Allow necessary traffic to lb"
	vpc_id = "${module.vpc.vpc_id}"

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}

	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}

	tags {
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
	}
}

# Create a new load balancer
resource "aws_lb" "lb" {
  name               = "${data.null_data_source.env_constants.outputs.load_balancer}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb.id}"]
  subnets            = ["${module.vpc.subnet_ids}"]

	enable_cross_zone_load_balancing = true
  enable_deletion_protection = true
	enable_http2 = true
	ip_address_type = "dualstack"

	tags {
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
	}
}

resource "aws_lb_target_group" "null" {
  name     = "${var.product}-${var.environment}-tg-null"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

	tags {
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
	}
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.null.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${data.aws_acm_certificate.lb.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.null.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "in_zone_ipv4" {
	count = "${length(split(" ", data.null_data_source.env_constants.outputs.load_balancer_records_main_zone))}"
	zone_id = "${data.aws_route53_zone.zone.zone_id}"
	name = "${element(split(" ", data.null_data_source.env_constants.outputs.load_balancer_records_main_zone), count.index)}"
	type = "A"

	alias {
    name = "${aws_lb.lb.dns_name}"
    zone_id = "${aws_lb.lb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "in_zone_ipv6" {
	count = "${length(split(" ", data.null_data_source.env_constants.outputs.load_balancer_records_main_zone))}"
	zone_id = "${data.aws_route53_zone.zone.zone_id}"
	name = "${element(split(" ", data.null_data_source.env_constants.outputs.load_balancer_records_main_zone), count.index)}"
	type = "AAAA"

	alias {
    name = "${aws_lb.lb.dns_name}"
    zone_id = "${aws_lb.lb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "svc_zone_ipv4" {
	count = "${length(split(" ", data.null_data_source.env_constants.outputs.load_balancer_records_services_zone))}"
	zone_id = "${data.aws_route53_zone.services.zone_id}"
	name = "${element(split(" ", data.null_data_source.env_constants.outputs.load_balancer_records_services_zone), count.index)}"
	type = "A"

	alias {
		name = "${aws_lb.lb.dns_name}"
    zone_id = "${aws_lb.lb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "svc_zone_ipv6" {
	count = "${length(split(" ", data.null_data_source.env_constants.outputs.load_balancer_records_services_zone))}"
	zone_id = "${data.aws_route53_zone.services.zone_id}"
	name = "${element(split(" ", data.null_data_source.env_constants.outputs.load_balancer_records_services_zone), count.index)}"
	type = "AAAA"

	alias {
		name = "${aws_lb.lb.dns_name}"
    zone_id = "${aws_lb.lb.zone_id}"
    evaluate_target_health = false
  }
}

## -- end of load balancing resources
