data "aws_caller_identity" "current" {}

variable "region" {
  type = string
  default = "eu-north-1"
}

locals {
  project_name = "video-box"
  region = "eu-north-1"
  account_id = data.aws_caller_identity.current.account_id

  tags = {
    Environment = "Production"
    Project     = local.project_name
  }
}