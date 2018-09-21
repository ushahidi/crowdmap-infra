data "aws_sns_topic" "alarm_notification" {
  name = "${var.product}-${var.environment}-alarm-notification"
}
