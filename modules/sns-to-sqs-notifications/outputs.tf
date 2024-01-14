output "sqs_url" {
  value = aws_sqs_queue.sqs_topic.url
}

output "sns_topic_arn" {
  value = aws_sns_topic.sns_notification_topic.arn
}