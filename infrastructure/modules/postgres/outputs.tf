output "url" {
  value = "postgresql://user:pass@${docker_container.postgres.ip_address}:5432/analytisc"
  description = "Database URI"
}