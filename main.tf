provider "aws" {
  region = "ap-south-1"
  profile = var.AWS_PROFILE
}

terraform {
  backend "s3" {
    bucket = "mitil-tfstates"
    key    = "prod/talon/terraform.tfstate"
    region = "ap-south-1"
  }
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

module "services" {
  source = "./modules/services"
  APP_NAME = var.APP_NAME
  PARAM_PREFIX = var.PARAM_PREFIX
  ENVIRONMENT = var.ENVIRONMENT
  DOCKER_IMAGE = var.DOCKER_IMAGE
  AWS_ACCOUNT =  var.AWS_ACCOUNT
  AWS_REGION = var.AWS_REGION
}
