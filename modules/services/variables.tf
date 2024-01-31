variable "APP_NAME" {
  type    = string
}

variable "AWS_REGION" {
  type = string
}

variable "AWS_ACCOUNT" {
  type = string
}

variable "ENVIRONMENT" {
    type = string
}


variable PARAM_PREFIX {
  type = string
}

variable "service_configs" {
  type = list(object({
    name    = string
    image   = string
    port    = number
    path    = string
    health_check_path = string
  }))
  default = [
    {
      name    = "MitilServerTgHttp"
      image   = "talon-server"
      port    = 9090
      path    = "/talon/api/*"
      health_check_path = "/ping"
    },
    # Add more service configurations as needed
  ]
}
