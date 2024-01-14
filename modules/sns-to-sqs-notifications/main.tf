resource "aws_sns_topic" "sns_notification_topic" {
  name = var.sns_topic_name

  delivery_policy = jsonencode({
    http: {
      defaultHealthyRetryPolicy: {
        minDelayTarget: 20,
        maxDelayTarget: 20,
        numRetries: 3,
        numMaxDelayRetries: 0,
        numNoDelayRetries: 0,
        numMinDelayRetries: 0,
        backoffFunction: "linear"
      },
      disableSubscriptionOverrides: false,
      defaultRequestPolicy: {
        headerContentType: "application/json"
      }
    }
  })
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn    = aws_sns_topic.sns_notification_topic.arn
  policy = data.aws_iam_policy_document.sns_metadata_series.json
}

data "aws_iam_policy_document" "sns_metadata_series" {
  policy_id = "${var.sns_topic_name}-policy"

  statement {
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [
      aws_sns_topic.sns_notification_topic.arn
    ]

    principals {
      identifiers = ["s3.amazonaws.com"]
      type       = "Service"
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [var.s3_bucket_arn]
    }
  }
}

resource "aws_sqs_queue" "sqs_topic" {
  name = var.sqs_topic_name
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.sqs_topic.id
  policy    = data.aws_iam_policy_document.sqs_topic_policy.json
}

data "aws_iam_policy_document" "sqs_topic_policy" {
  policy_id = "${var.sqs_topic_name}-policy"

  statement {
    effect    = "Allow"
    actions   = ["SQS:SendMessage"]
    resources = [aws_sqs_queue.sqs_topic.arn]

    principals {
      identifiers = ["sns.amazonaws.com"]
      type       = "Service"
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.sns_notification_topic.arn]
    }
  }
}

resource "aws_sns_topic_subscription" "metadata_series_update_target" {
  topic_arn = aws_sns_topic.sns_notification_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_topic.arn
}