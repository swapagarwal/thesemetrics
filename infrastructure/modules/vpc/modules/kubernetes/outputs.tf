output "config" {
  value = {
    host                   = digitalocean_kubernetes_cluster.default.endpoint
    token                  = digitalocean_kubernetes_cluster.default.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate)
  }
}