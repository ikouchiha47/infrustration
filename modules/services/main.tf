provider "aws" {
  region = "ap-south-1"
  profile = var.AWS_PROFILE
}

terraform {
  backend "s3" {}
}
