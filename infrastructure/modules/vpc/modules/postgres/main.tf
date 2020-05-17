locals {
  size  = "db-s-1vcpu-1gb"
  nodes = 1

  version = "11"

  db_name    = "analytics"
  app_user   = "app"
  pixel_user = "app"
  job_user   = "job"

  app_pool_size   = "6"
  pixel_pool_size = "14"
  job_pool_size   = "2"

  project = var.project
  region  = var.region
  tag     = var.tag
  vpc     = var.private_network_uuid
}

resource "digitalocean_database_cluster" "postgres" {
  name                 = "pg0"
  engine               = "pg"
  size                 = local.size
  region               = local.region
  version              = local.version
  node_count           = local.nodes
  private_network_uuid = local.vpc
}

resource "digitalocean_project_resources" "postgres" {
  project = local.project
  resources = [
    digitalocean_database_cluster.postgres.urn
  ]
}

resource "digitalocean_database_firewall" "pg_firewall" {
  cluster_id = digitalocean_database_cluster.postgres.id

  rule {
    type  = "tag"
    value = local.tag
  }
}

resource "digitalocean_database_db" "analytics" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = local.db_name
}

resource "digitalocean_database_connection_pool" "pg_app_connection" {
  cluster_id = digitalocean_database_cluster.postgres.id

  name    = "pg-thesemetrics-app-pool"
  mode    = "transaction"
  size    = local.app_pool_size
  db_name = digitalocean_database_db.analytics.name
  user    = local.app_user
}

resource "digitalocean_database_connection_pool" "pg_pixel_connection" {
  cluster_id = digitalocean_database_cluster.postgres.id

  name    = "pg-thesemetrics-pixel-pool"
  mode    = "transaction"
  size    = local.pixel_pool_size
  db_name = digitalocean_database_db.analytics.name
  user    = local.pixel_user
}

resource "digitalocean_database_connection_pool" "pg_job_connection" {
  cluster_id = digitalocean_database_cluster.postgres.id

  name    = "pg-thesemetrics-job-pool"
  mode    = "transaction"
  size    = local.job_pool_size
  db_name = digitalocean_database_db.analytics.name
  user    = local.job_user
}
