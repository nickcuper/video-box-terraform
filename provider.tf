terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.3"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = local.tags
  }
}