output "load_balancers" {
  value = kubernetes_ingress.default.load_balancer_ingress
}
