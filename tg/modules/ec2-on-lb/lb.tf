data "aws_lb" "lb" {
  name = "${var.load_balancer_name}"
}

data "aws_lb_listener" "lb_http" {
  load_balancer_arn = "${data.aws_lb.lb.arn}"
  port = "80"
}

data "aws_lb_listener" "lb_https" {
  load_balancer_arn = "${data.aws_lb.lb.arn}"
  port = "443"
}

resource "aws_lb_target_group" "tg" {
  name     = "${substr(md5(var.load_balancer_name), 16, 16)}-tg-${replace(var.component, "_", "-")}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

	health_check {
		healthy_threshold = 5
		unhealthy_threshold = 2
		timeout = 5
		path = "${var.health_check_path}"
		interval = 15
    matcher = "${var.health_check_status_match}"
	}

	tags {
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
	}
}

resource "aws_lb_target_group_attachment" "tg" {
	count = "${var.instance_count}"
  target_group_arn = "${aws_lb_target_group.tg.arn}"
  target_id        = "${element(aws_instance.instance.*.id, count.index)}"
  port             = 80
}

resource "aws_lb_listener_rule" "http" {
  count = "${length(var.hostnames)}"
  listener_arn = "${data.aws_lb_listener.lb_http.arn}"
  priority     = "${var.listener_rule_priority + count.index}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg.arn}"
  }

  condition {
    field  = "host-header"
    values = [ "${element(var.hostnames, count.index)}" ]
  }
}

resource "aws_lb_listener_rule" "https" {
  count = "${length(var.hostnames)}"
  listener_arn = "${data.aws_lb_listener.lb_https.arn}"
  priority     = "${var.listener_rule_priority + count.index}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg.arn}"
  }

  condition {
    field  = "host-header"
    values = [ "${element(var.hostnames, count.index)}" ]
  }
}
