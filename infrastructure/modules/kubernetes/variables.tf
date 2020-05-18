variable "app_replicas" {
  type    = number
  default = 2
}

variable "pixel_replicas" {
  type    = number
  default = 3
}

variable "db_certificate" {
  type = string
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

variable "tls_certifacte" {
  type = string
}

variable "tls_private_key" {
  type = string
}
