provider "aws" {
  region = "ap-south-1"
  profile = var.AWS_PROFILE
}

terraform {
  backend "s3" {}
}

// create IAM policies
// create certificates

// Create a auto scaling group which with a variable
// ECS_CLUSTER set to server Cluster


module "iam_policies" {
 source = "./modules/iam"
}

module "networking" {
  source = "./modules/networking"
  ENVIRONMENT = var.ENVIRONMENT
}

