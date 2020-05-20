output "loadbalancer_ip" {
  value = digitalocean_loadbalancer.default.ip
}

output "docker_host" {
  value = digitalocean_droplet.swarm.ipv4_address

  depends_on = [digitalocean_droplet.swarm]
}
