variable "database_uri" {
  type = object({
    app   = string
    pixel = string
    job   = string
  })
}

variable "traefik_token" {
  type = string
}

variable "database_ssl_certificate" {
  type = string
}

variable "domain" {
  type    = string
  default = "thesemetrics.xyz"
}

variable "ingress_port" {
  type    = number
  default = 80
}

variable "scale" {
  type = object({
    app     = number
    pixel   = number
    ingress = number
  })

  default = {
    app     = 2
    pixel   = 4
    ingress = 2
  }
}
