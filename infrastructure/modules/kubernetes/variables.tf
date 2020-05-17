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

variable "app_database_uri" {
  type = string
}

variable "pixel_database_uri" {
  type = string
}

variable "job_database_uri" {
  type = string
}
