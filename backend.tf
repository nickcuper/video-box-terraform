terraform {
  backend "s3" {
    bucket         = "video-box-terraform-state"
    key            = "state/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "terraform-state"
  }
}