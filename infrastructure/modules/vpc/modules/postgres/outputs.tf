output "app_db_uri" {
  value       = digitalocean_database_connection_pool.pg_app_connection.uri
  description = "Application Database Connection"
}

output "pixel_db_uri" {
  value       = digitalocean_database_connection_pool.pg_app_connection.uri
  description = "Pixel Collector Database Connection"
}

output "job_db_uri" {
  value       = digitalocean_database_connection_pool.pg_app_connection.uri
  description = "Aggregator Database Connection"
}
