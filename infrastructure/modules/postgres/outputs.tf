output "uri" {
  value       = "postgresql://user:pass@${docker_container.postgres.ip_address}:5432/analytics"
  description = "Database URI"

  depends_on = [
    docker_service.postgres
  ]
}
