variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "tag" {
  type = string
}

variable "tls" {
  type = object({
    private_key = string
    certificate = string
  })
}

variable "ssh_key" {
  type = object({
    public  = string
    private = string
  })
}

variable "private_network_uuid" {
  type = string
}
