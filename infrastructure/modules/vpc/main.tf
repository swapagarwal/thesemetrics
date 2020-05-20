locals {
  region = var.region
}

resource "digitalocean_project" "default" {
  name        = "TheseMetrics"
  description = "Simple application analytics."
  purpose     = "Web Application"
  environment = "Production"
}

resource "digitalocean_tag" "app" {
  name = "TheseMetrics"
}

resource "digitalocean_vpc" "default" {
  name     = "default-${var.region}"
  region   = var.region
  ip_range = "10.130.0.0/16"
}

module "postgres" {
  source = "./modules/postgres"

  project = digitalocean_project.default.id
  region  = local.region
  tag     = digitalocean_tag.app.id

  private_network_uuid = digitalocean_vpc.default.id
}

module "swarm" {
  source = "./modules/swarm"

  project = digitalocean_project.default.id
  region  = local.region
  tag     = digitalocean_tag.app.id

  private_network_uuid = digitalocean_vpc.default.id

  ssh_key = var.ssh_key
  tls = var.tls
}
