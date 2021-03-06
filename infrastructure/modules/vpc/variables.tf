variable "region" {
  type    = string
  default = "nyc1"
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
