locals {
  zone = "thesemetrics.xyz"
}

resource "cloudflare_zone" "default" {
  zone = local.zone
}

resource "cloudflare_record" "_default" {
  zone_id = cloudflare_zone.default.id

  name    = "@"
  value   = "thesemetrics.netlify.app"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "_www" {
  zone_id = cloudflare_zone.default.id

  name    = "www"
  value   = "thesemetrics.netlify.app"
  type    = "CNAME"
  ttl     = 3600
  proxied = false
}

resource "cloudflare_record" "pixel" {
  zone_id = cloudflare_zone.default.id

  for_each = var.loadbalancer_ips

  name    = "pixel"
  value   = each.key
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "app" {
  zone_id = cloudflare_zone.default.id

  for_each = var.loadbalancer_ips

  name    = "api"
  value   = each.key
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "traefik" {
  zone_id = cloudflare_zone.default.id

  for_each = var.loadbalancer_ips

  name    = "traefik"
  value   = each.key
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "portainer" {
  zone_id = cloudflare_zone.default.id

  for_each = var.loadbalancer_ips

  name    = "portainer"
  value   = each.key
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zone_settings_override" "default" {
  zone_id = cloudflare_zone.default.id

  settings {
    always_use_https         = "on"

    brotli              = "on"
    opportunistic_onion = "on"
    ip_geolocation      = "on"

    challenge_ttl = 2700

    ssl     = "strict"
    
    security_header {
      enabled = true
      nosniff = true

      include_subdomains = true
    }
  }
}
