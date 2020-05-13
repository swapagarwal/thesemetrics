output "ip_address" {
  value = kubernetes_ingress.default.load_balancer_ingress
}
