provider "digitalocean" {
  version = "~> 1.18"

  token = var.do_token
}

module "vpc" {
  source = "../modules/vpc"
}

provider "kubernetes" {
  version = "~> 1.11"

  load_config_file = false

  host  = module.vpc.kubernetes.host
  token = module.vpc.kubernetes.token

  cluster_ca_certificate = module.vpc.kubernetes.cluster_ca_certificate
}

module "kubernetes" {
  source = "../modules/kubernetes"

  app_replicas          = 1
  pixel_replicas        = 1
  docker_registry_token = var.docker_registry_token
  app_database_uri      = module.vpc.app_database_uri
  pixel_database_uri    = module.vpc.pixel_database_uri
  job_database_uri      = module.vpc.job_database_uri
}

provider "cloudflare" {
  version = "~> 2.6"

  api_token = var.cloudflare_token
}

module "cloudflare" {
  source = "../modules/cloudflare"

  loadbalancer_ip = module.kubernetes.load_balancers[0].ip
}
