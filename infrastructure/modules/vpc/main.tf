locals {
  region = var.region
}

module "postgres" {
  source = "./modules/postgres"

  project = digitalocean_project.default.id
  region  = local.region
  tag     = digitalocean_tag.app.id

  private_network_uuid = digitalocean_vpc.default.id
}

module "kubernetes" {
  source = "./modules/kubernetes"

  project = digitalocean_project.default.id
  region  = local.region
  tag     = digitalocean_tag.app.id

  private_network_uuid = digitalocean_vpc.default.id
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
  name     = "default"
  region   = var.region
  ip_range = "10.10.10.0/24"
}
