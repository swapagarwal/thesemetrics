resource "docker_container" "postgres" {
  name  = "postgres"
  image = "postgres:11-alpine"

  must_run = true
  start    = true

  env = [
    "POSTGRES_USER=user",
    "POSTGRES_PASSWORD=pass",
    "POSTGRES_DB=analytics"
  ]

  ports {
    ip       = "0.0.0.0"
    internal = 5432
    external = 5432
  }
}

