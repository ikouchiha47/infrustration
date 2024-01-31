variable "AWS_ACCOUNT" {
  type = string
}

variable "AWS_PROFILE" {
 type = string
 default = "default"
}

variable "AWS_REGION" {
  type = string
  default = "ap-south-1"
}

variable "ENVIRONMENT" {
  type = string
  default = "beta"
}

variable APP_NAME {
  type = string
}

variable PARAM_PREFIX {
  type = string
}

