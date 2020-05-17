output "app_database_uri" {
  value       = module.postgres.app_db_uri
  description = "Application Database Connection"
}

output "pixel_database_uri" {
  value       = module.postgres.pixel_db_uri
  description = "Pixel Collector Database Connection"
}

output "job_database_uri" {
  value       = module.postgres.job_db_uri
  description = "Aggregator Database Connection"
}

output "kubernetes" {
  value       = module.kubernetes.config
  description = "Kubernetes"
}
