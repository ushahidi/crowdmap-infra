resource "aws_sns_topic" "alarm_notification" {
	name = "${var.product}-${var.environment}-alarm-notification"
}

resource "aws_sns_topic_subscription" "opsgenie-alarm-subscription" {
	count = "${var.opsgenie_integration_endpoint != "" ? 1 : 0}"
	topic_arn = "${aws_sns_topic.alarm_notification.arn}"
	protocol = "https"
	endpoint = "${var.opsgenie_integration_endpoint}"
	endpoint_auto_confirms = true
	confirmation_timeout_in_minutes = 5
}
