terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "znck"

    workspaces {
      name = "thesemetrics"
    }
  }
}

provider "null" {
  version = "~> 2.1"
}

provider "digitalocean" {
  version = "~> 1.18"

  token = var.do_token
}

provider "acme" {
  version    = "~> 1.5"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}


provider "cloudflare" {
  version = "~> 2.6"

  api_token = var.cloudflare_token
}

module "acme" {
  source = "../modules/acme"

  cloudflare_token = var.cloudflare_token
  private_key_pem  = var.private_key_pem
}

module "vpc" {
  source = "../modules/vpc"

  ssh_key = {
    private = var.deploy_ssh_private_key
    public  = var.deploy_ssh_public_key
  }

  tls = {
    private_key = module.acme.private_key
    certificate = module.acme.certificate
  }
}

module "cloudflare" {
  source = "../modules/cloudflare"

  loadbalancer_ips = module.vpc.ips
}

provider "docker" {
  version = "~> 2.7"

  host = "ssh://root@161.35.252.32"

  registry_auth {
    address  = "docker.pkg.github.com"
    username = "znck"
    password = var.docker_registry_token
  }
}

module "services" {
  source = "../modules/services"

  traefik_token = var.traefik_token

  database_uri = {
    app   = module.vpc.app_database_uri
    job   = module.vpc.job_database_uri
    pixel = module.vpc.pixel_database_uri
  }

  database_ssl_certificate = var.db_certificate

  domain = "thesemetrics.xyz"

  ingress_port = 80

  scale = {
    app     = 2
    pixel   = 4
    ingress = 1
  }
}
