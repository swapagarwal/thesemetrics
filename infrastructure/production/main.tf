terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "znck"

    workspaces {
      name = "thesemetrics"
    }
  }
}

provider "digitalocean" {
  version = "~> 1.18"

  token = var.do_token
}

module "vpc" {
  source = "../modules/vpc"
}

provider "acme" {
  version    = "~> 1.5"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

module "acme" {
  source = "../modules/acme"

  cloudflare_token = var.cloudflare_token
  private_key_pem  = var.private_key_pem
}

provider "kubernetes" {
  version = "~> 1.11"

  load_config_file = false

  host  = module.vpc.kubernetes.host
  token = module.vpc.kubernetes.token

  cluster_ca_certificate = module.vpc.kubernetes.cluster_ca_certificate
}

module "ingress" {
  source = "../modules/ingress"
}

module "kubernetes" {
  source = "../modules/kubernetes"

  app_replicas          = 1
  pixel_replicas        = 1
  docker_registry_token = var.docker_registry_token
  app_database_uri      = module.vpc.app_database_uri
  pixel_database_uri    = module.vpc.pixel_database_uri
  job_database_uri      = module.vpc.job_database_uri
  tls_certifacte        = module.acme.certificate
  tls_private_key       = module.acme.private_key
  db_certificate        = var.db_certificate
}

provider "cloudflare" {
  version = "~> 2.6"

  api_token = var.cloudflare_token
}

module "cloudflare" {
  source = "../modules/cloudflare"

  # loadbalancer_ip = module.kubernetes.load_balancers[0].ip
}
