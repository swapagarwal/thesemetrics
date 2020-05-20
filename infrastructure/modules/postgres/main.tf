resource "docker_image" "postgres" {
  name = "postgres:11-alpine"
}


resource "docker_container" "postgres" {
  depends_on = [var.network_id]

  name = "postgres"

  networks_advanced {
    name = "thesemetrics"
  }

  image    = docker_image.postgres.latest
  hostname = "database"

  env = [
    "POSTGRES_USER=user",
    "POSTGRES_PASSWORD=pass",
    "POSTGRES_DB=analytics",
  ]

  lifecycle {
    create_before_destroy = false

    ignore_changes = [env]
  }

  provisioner "local-exec" {
    command = "sleep 2"
  }
}

