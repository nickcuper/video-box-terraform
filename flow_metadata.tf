resource "aws_s3_bucket" "metadata" {
  bucket = "${local.project_name}-metadata"

  force_destroy = false
}

resource "aws_s3_bucket_versioning" "metadata" {
  bucket = aws_s3_bucket.metadata.id

  versioning_configuration {
    status = "Enabled"
  }
}

module "metadata_movie_notifications" {
  source = "./modules/sns-to-sqs-notifications"

  sns_topic_name = "${local.project_name}-metadata-movie"
  sqs_topic_name = "${local.project_name}-themoviedb-metadata-movie"
  s3_bucket_arn  = aws_s3_bucket.metadata.arn
}

module "metadata_series_notifications" {
  source = "./modules/sns-to-sqs-notifications"

  sns_topic_name = "${local.project_name}-metadata-series"
  sqs_topic_name = "${local.project_name}-themoviedb-metadata-series"
  s3_bucket_arn  = aws_s3_bucket.metadata.arn
}

resource "aws_s3_bucket_notification" "bucket_notifications" {
  bucket = aws_s3_bucket.metadata.id

  topic {
    id          = "${local.project_name}-metadata-series-notifications"
    topic_arn   = module.metadata_series_notifications.sns_topic_arn
    filter_prefix = "themoviedb/series/"
    events      = ["s3:ObjectCreated:*"]
  }

  topic {
    id          = "${local.project_name}-metadata-movie-notifications"
    topic_arn   = module.metadata_movie_notifications.sns_topic_arn
    filter_prefix = "themoviedb/movie/"
    events      = ["s3:ObjectCreated:*"]
  }
}