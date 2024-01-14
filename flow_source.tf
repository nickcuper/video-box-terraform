resource "aws_s3_bucket" "source" {
  bucket = "${local.project_name}-source"

  force_destroy = false
}

resource "aws_s3_bucket_versioning" "source" {
  bucket = aws_s3_bucket.source.id

  versioning_configuration {
    status = "Enabled"
  }
}

module "source_movie_notifications" {
  source = "./modules/sns-to-sqs-notifications"

  sns_topic_name = "${local.project_name}-source-movie"
  sqs_topic_name = "${local.project_name}-source-filmix-movie"
  s3_bucket_arn  = aws_s3_bucket.source.arn
}

module "source_series_notifications" {
  source = "./modules/sns-to-sqs-notifications"

  sns_topic_name = "${local.project_name}-source-series"
  sqs_topic_name = "${local.project_name}-source-filmix-series"
  s3_bucket_arn  = aws_s3_bucket.source.arn
}

resource "aws_s3_bucket_notification" "source_bucket_notifications" {
  bucket = aws_s3_bucket.source.id

  topic {
    id          = "${local.project_name}-source-filmix-series-notifications"
    topic_arn   = module.source_series_notifications.sns_topic_arn
    filter_prefix = "filmix/series/"
    events      = ["s3:ObjectCreated:*"]
  }

  topic {
    id          = "${local.project_name}-source-filmix-movie-notifications"
    topic_arn   = module.source_movie_notifications.sns_topic_arn
    filter_prefix = "filmix/movie/"
    events      = ["s3:ObjectCreated:*"]
  }
}