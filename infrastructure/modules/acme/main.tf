locals {
  private_key_pem = var.private_key_pem
  cloudflare_token = var.cloudflare_token
}

resource "acme_registration" "default" {
  account_key_pem = local.private_key_pem
  email_address   = "rahulkdn@gmail.com"
}

resource "acme_certificate" "default" {
  account_key_pem = local.private_key_pem
  
  common_name               = "thesemetrics.xyz"
  subject_alternative_names = ["*.thesemetrics.xyz"]

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_DNS_API_TOKEN = local.cloudflare_token
    }
  }
}
