variable "DOCKER_IMAGE" {
  type = string
}

variable "AWS_ACCOUNT" {
  type = string
}

variable "AWS_PROFILE" {
 type = string
 default = "default"
}

variable "ENVIRONMENT" {
  type = string
  default = "beta"
}
