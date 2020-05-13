output "url" {
  value = "postgresql://user:pass@${docker_container.postgres.network_data.ip_address}:5432/analytisc"
  description = "Database URI"
}