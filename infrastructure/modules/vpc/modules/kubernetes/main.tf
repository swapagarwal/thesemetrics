locals {
  size = "s-1vcpu-2gb"

  project = var.project
  region  = var.region
  tag     = var.tag
  vpc     = var.private_network_uuid
}


data "digitalocean_kubernetes_versions" "kube" {}

resource "digitalocean_kubernetes_cluster" "default" {
  name     = "kube0"
  version  = data.digitalocean_kubernetes_versions.kube.latest_version
  region   = local.region
  vpc_uuid = local.vpc

  tags = [
    local.tag
  ]

  node_pool {
    name = "pool0"
    size = local.size

    auto_scale = true
    min_nodes  = 1
    max_nodes  = 2

    labels = {
      priority = "high"
    }

    tags = [
      local.tag
    ]
  }
}

