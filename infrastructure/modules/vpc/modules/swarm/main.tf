resource "digitalocean_certificate" "default" {
  name = md5(var.tls.certificate)
  type = "custom"

  private_key      = var.tls.private_key
  leaf_certificate = var.tls.certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_ssh_key" "deploy" {
  name       = "thesemetrics-deploy-key"
  public_key = var.ssh_key.public
}

resource "digitalocean_tag" "ingress" {
  name = "TheseMetrics::Ingress"
}

resource "digitalocean_droplet" "swarm" {

  name     = "thesemetrics-swarm-manager0"
  size     = "s-1vcpu-1gb"
  image    = "docker-18-04"
  region   = var.region
  vpc_uuid = var.private_network_uuid

  monitoring = true

  ssh_keys = [digitalocean_ssh_key.deploy.fingerprint]

  tags = [var.tag, digitalocean_tag.ingress.id]

  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_floating_ip" "swarm" {
  droplet_id = digitalocean_droplet.swarm.id
  region     = digitalocean_droplet.swarm.region

   lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_firewall" "default" {
  name = "thesemetrics"

  tags = [var.tag]

  droplet_ids = [digitalocean_droplet.swarm.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["10.130.0.0/16"]
  }
  
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_loadbalancer" "default" {
  name     = "thesemetrics0"
  region   = var.region
  vpc_uuid = var.private_network_uuid

  algorithm                = "least_connections"
  redirect_http_to_https   = true
  enable_proxy_protocol    = false
  enable_backend_keepalive = false

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_id = digitalocean_certificate.default.id
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.swarm.id]
}

resource "digitalocean_project_resources" "swarm" {
  project = var.project

  resources = flatten([
    [digitalocean_loadbalancer.default.urn, digitalocean_droplet.swarm.urn, digitalocean_floating_ip.swarm.urn],
  ])
}
