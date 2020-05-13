variable "app_replicas" {
  type    = number
  default = 2
}

variable "pixel_replicas" {
  type    = number
  default = 3
}

variable "docker_registry_token" {
  type = string
}

variable "database_uri" {
  type = string
}
