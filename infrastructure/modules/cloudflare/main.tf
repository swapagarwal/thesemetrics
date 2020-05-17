locals {
  zone = "thesemetrics.xyz"

  ip = var.loadbalancer_ip
}

resource "cloudflare_zone" "default" {
  zone = local.zone
  plan = "free"
}

resource "cloudflare_record" "_default" {
  zone_id = cloudflare_zone.default.id

  name    = "@"
  value   = local.ip
  type    = "A"
  ttl     = 3600
  proxied = true
}

resource "cloudflare_record" "_wildcard" {
  zone_id = cloudflare_zone.default.id

  name    = "*"
  value   = local.ip
  type    = "A"
  ttl     = 3600
  proxied = true
}

resource "cloudflare_zone_settings_override" "default" {
  zone_id = cloudflare_zone.default.id

  settings {
    development_mode = "off"
    always_online    = "on"

    always_use_https         = "on"
    automatic_https_rewrites = "on"

    browser_check = "on"

    ipv6  = "on"
    http3 = "on"

    brotli              = "on"
    zero_rtt            = "on"
    opportunistic_onion = "on"
    ip_geolocation      = "on"

    ssl = "full"
    security_header {
      enabled = true
      nosniff = true

      include_subdomains = true
    }
  }
}
