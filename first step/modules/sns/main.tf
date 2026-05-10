resource "aws_sns_topic" "upload_alerts" {
  name = "S3UploadAlerts"
}

resource "aws_sns_topic_subscription" "email_target" {

  topic_arn = aws_sns_topic.upload_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}