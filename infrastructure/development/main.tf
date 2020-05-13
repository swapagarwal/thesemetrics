provider "docker" {
  version = "~> 2.7"
}

module "database" {
  source = "../modules/postgres"
}


provider "kubernetes" {
  version = "~> 1.11"
}

module "kubernetes" {
  source = "../modules/kubernetes"

  app_replicas          = 1
  pixel_replicas        = 1
  docker_registry_token = var.docker_registry_token
  database_uri          = module.database.url
}
