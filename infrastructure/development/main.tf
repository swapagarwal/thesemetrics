provider "docker" {
  version = "~> 2.7"
}

module "db" {
  source = "../modules/postgres"

  network_id = module.services.network_id
}

module "services" {
  source = "../modules/services"

  traefik_token = "admin:$2y$10$3LLtrRvMyRqUJQTBRRvcuuVG8ee0LEJZ1H3lnjL26ksMzBLCRkGqG" // admin:admin

  database_uri = {
    app   = module.db.uri
    job   = module.db.uri
    pixel = module.db.uri
  }


  database_ssl_certificate = "IGNORE"

  domain = "thesemetrics.xyz.develop"

  ingress_port = 8081
  
  scale = {
    app     = 2
    pixel   = 2
    ingress = 1
  }
}

