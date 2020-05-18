locals {
  app   = digitalocean_database_connection_pool.pg_app_connection
  pixel = digitalocean_database_connection_pool.pg_pixel_connection
  job   = digitalocean_database_connection_pool.pg_job_connection
}


output "app_db_uri" {
  value       = replace(local.app.private_uri, "/\\?sslmode=require$/", "")
  description = "Application Database Connection"
}

output "pixel_db_uri" {
  value       = replace(local.pixel.private_uri, "/\\?sslmode=require$/", "")
  description = "Pixel Collector Database Connection"
}

output "job_db_uri" {
  value       = replace(local.job.private_uri, "/\\?sslmode=require$/", "")
  description = "Aggregator Database Connection"
}
