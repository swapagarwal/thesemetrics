# Images
locals {
  version = "0.1.7"
}

resource "docker_image" "traefik" {
  name = "traefik:v2.2"
}

resource "docker_image" "db" {
  name = "docker.pkg.github.com/znck/thesemetrics/db:${local.version}"
}

resource "docker_image" "app" {
  name = "docker.pkg.github.com/znck/thesemetrics/app:${local.version}"
}

resource "docker_image" "pixel" {
  name = "docker.pkg.github.com/znck/thesemetrics/pixel:${local.version}"
}

resource "docker_image" "portainer" {
  name = "portainer/portainer"
}

resource "docker_image" "portainer_agent" {
  name = "portainer/agent"
}

resource "docker_image" "cron" {
  name = "crazymax/swarm-cronjob"
}

# Networks
resource "docker_network" "public" {
  name   = "thesemetrics"
  driver = "overlay"

  attachable = true
}

# Secrets
resource "docker_secret" "database_ssl_certificate" {
  name = "database_ssl_certificate_${substr(sha256(var.database_ssl_certificate), 56, 8)}"
  data = base64encode(var.database_ssl_certificate)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "docker_secret" "pixel_database_uri" {
  name = "pixel_database_uri_${substr(sha256(var.database_uri.pixel), 56, 8)}"
  data = base64encode(var.database_uri.pixel)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "docker_secret" "app_database_uri" {
  name = "app_database_uri_${substr(sha256(var.database_uri.app), 56, 8)}"
  data = base64encode(var.database_uri.app)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "docker_secret" "job_database_uri" {
  name = "job_database_uri_${substr(sha256(var.database_uri.job), 56, 8)}"
  data = base64encode(var.database_uri.job)
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

# Configs
resource "docker_config" "traefik" {
  name = "traefik-${replace(timestamp(), ":", ".")}"
  data = base64encode(file("${path.module}/traefik.toml"))

  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

# Services
resource "docker_service" "traefik" {
  name = "traefik"

  depends_on = [docker_service.migrate]

  labels {
    label = "traefik.enable"
    value = true
  }

  labels {
    label = "traefik.http.routers.api.rule"
    value = "Host(`traefik.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.api.entrypoints"
    value = "http"
  }

  labels {
    label = "traefik.http.routers.api.service"
    value = "api@internal"
  }

  labels {
    label = "traefik.http.services.api.loadbalancer.server.port"
    value = 80
  }

  labels {
    label = "traefik.http.routers.api.middlewares"
    value = "auth"
  }

  labels {
    label = "traefik.http.middlewares.auth.basicauth.users"
    value = var.traefik_token
  }

  task_spec {
    networks = [docker_network.public.id]

    restart_policy = {
      condition    = "on-failure"
      max_attempts = 3
    }

    placement {
      constraints = ["node.role==manager"]
      platforms {
        architecture = "amd64"
        os           = "linux"
      }
    }

    container_spec {
      image = docker_image.traefik.latest

      configs {
        config_id   = docker_config.traefik.id
        config_name = docker_config.traefik.name
        file_name   = "/etc/traefik/traefik.toml"
      }

      mounts {
        type   = "bind"
        source = "/var/run/docker.sock"
        target = "/var/run/docker.sock"
      }
    }
  }

  mode {
    replicated {
      replicas = var.scale.ingress
    }
  }

  endpoint_spec {
    ports {
      target_port    = 80
      published_port = var.ingress_port
      publish_mode   = "ingress"
    }
  }
}

resource "docker_volume" "portainer" {
  name = "portainer-data"
}

resource "docker_service" "portainer" {
  name = "portainer"

  depends_on = [docker_service.portainer_agent]

  labels {
    label = "traefik.enable"
    value = true
  }

  labels {
    label = "traefik.http.routers.portainer.rule"
    value = "Host(`portainer.${var.domain}`)"
  }

  labels {
    label = "traefik.http.services.portainer.loadbalancer.server.port"
    value = 9000
  }

  task_spec {
    networks = [docker_network.public.id]

    restart_policy = {
      condition    = "any"
      max_attempts = 5
    }

    placement {
      constraints = ["node.role==manager"]
      platforms {
        architecture = "amd64"
        os           = "linux"
      }
    }

    container_spec {
      image             = docker_image.portainer.latest
      stop_grace_period = "5s"
      args              = ["-H", "tcp://portainer_agent:9001", "--tlsskipverify"]

      mounts {
        type   = "volume"
        target = "/data"
        source = docker_volume.portainer.name
      }
    }

    force_update = 0
  }

  mode {
    replicated {
      replicas = 1
    }
  }

  update_config {
    parallelism = 1
    monitor     = "1s"
    order       = "start-first"
  }
}

resource "docker_service" "portainer_agent" {
  name = "portainer_agent"

  task_spec {
    networks = [docker_network.public.id]

    restart_policy = {
      condition    = "any"
      max_attempts = 5
    }

    placement {
      constraints = ["node.platform.os == linux"]
      platforms {
        architecture = "amd64"
        os           = "linux"
      }
    }

    container_spec {
      image             = docker_image.portainer_agent.latest
      stop_grace_period = "5s"

      mounts {
        type   = "bind"
        source = "/var/run/docker.sock"
        target = "/var/run/docker.sock"
      }

      mounts {
        type   = "bind"
        source = "/var/lib/docker/volumes"
        target = "/var/lib/docker/volumes"
      }
    }

    force_update = 0
  }

  mode {
    global = true
  }
}

resource "docker_service" "pixel" {
  name = "pixel"

  depends_on = [docker_service.migrate]

  labels {
    label = "traefik.enable"
    value = true
  }

  labels {
    label = "traefik.http.routers.pixel.rule"
    value = "Host(`pixel.${var.domain}`)"
  }

  labels {
    label = "traefik.http.services.pixel.loadbalancer.server.port"
    value = 3001
  }

  # labels {
  #   label = "traefik.http.services.pixel.loadbalancer.server.healthCheck.path"
  #   value = "/health"
  # }

  task_spec {
    networks = [docker_network.public.id]

    restart_policy = {
      condition    = "any"
      max_attempts = 5
    }

    container_spec {
      image = docker_image.pixel.latest

      env = {
        NODE_ENV = "production"
      }

      secrets {
        secret_id   = docker_secret.pixel_database_uri.id
        secret_name = docker_secret.pixel_database_uri.name
        file_name   = "/var/secrets/database_uri"
      }

      secrets {
        secret_id   = docker_secret.database_ssl_certificate.id
        secret_name = docker_secret.database_ssl_certificate.name
        file_name   = "/var/secrets/database_ssl_certificate"
      }

      stop_grace_period = "5s"
    }

    force_update = 0
  }

  mode {
    replicated {
      replicas = var.scale.pixel
    }
  }

  update_config {
    parallelism = 1
    monitor     = "1s"
    order       = "start-first"
  }
}

resource "docker_service" "app" {
  name = "app"

  depends_on = [docker_service.migrate]

  labels {
    label = "traefik.enable"
    value = true
  }

  labels {
    label = "traefik.http.routers.app.rule"
    value = "Host(`api.${var.domain}`)"
  }

  labels {
    label = "traefik.http.services.app.loadbalancer.server.port"
    value = 3000
  }

  task_spec {
    networks = [docker_network.public.id]

    restart_policy = {
      condition    = "any"
      max_attempts = 3
    }

    container_spec {
      image = docker_image.app.latest

      env = {
        NODE_ENV = "production"
      }

      secrets {
        secret_id   = docker_secret.app_database_uri.id
        secret_name = docker_secret.app_database_uri.name
        file_name   = "/var/secrets/database_uri"
      }

      secrets {
        secret_id   = docker_secret.database_ssl_certificate.id
        secret_name = docker_secret.database_ssl_certificate.name
        file_name   = "/var/secrets/database_ssl_certificate"
      }

      stop_grace_period = "5s"
    }

    force_update = 0
  }

  mode {
    replicated {
      replicas = var.scale.app
    }
  }
}

# Deployment Jobs
resource "docker_service" "migrate" {
  name = "migrate"

  task_spec {
    networks = [docker_network.public.id]

    restart_policy = {
      condition    = "on-failure"
      max_attempts = 3
      delay        = "2s"
    }

    container_spec {
      image = docker_image.db.latest

      command = ["npm"]
      args    = ["run", "migrate"]

      env = {
        NODE_ENV = "production"
      }

      secrets {
        secret_id   = docker_secret.job_database_uri.id
        secret_name = docker_secret.job_database_uri.name
        file_name   = "/var/secrets/database_uri"
      }

      secrets {
        secret_id   = docker_secret.database_ssl_certificate.id
        secret_name = docker_secret.database_ssl_certificate.name
        file_name   = "/var/secrets/database_ssl_certificate"
      }

      stop_grace_period = "5s"
    }

    force_update = 0
  }

  mode {
    global = true
  }

  lifecycle {
    create_before_destroy = false
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# CRON Service
resource "docker_service" "cron" {
  name = "cron"

  task_spec {
    networks = [docker_network.public.id]

    restart_policy = {
      condition    = "any"
      max_attempts = 5
    }

    placement {
      constraints = ["node.role == manager"]
      platforms {
        architecture = "amd64"
        os           = "linux"
      }
    }

    container_spec {
      image             = docker_image.cron.latest
      stop_grace_period = "5s"

      mounts {
        type   = "bind"
        source = "/var/run/docker.sock"
        target = "/var/run/docker.sock"
      }

      env = {
        TZ = "America/New_York"
      }
    }

    force_update = 0
  }

  mode {
    global = true
  }
}

# CRON Jobs
resource "docker_service" "aggregate" {
  name = "aggregate"

  labels {
    label = "swarm.cronjob.enable"
    value = true
  }
  
  labels {
    label = "swarm.cronjob.schedule"
    value = "5 0 * * *"
  }

  task_spec {
    networks = [docker_network.public.id]

    restart_policy = {
      condition = "none"
    }

    container_spec {
      image = docker_image.db.latest

      command = ["npm"]
      args    = ["run", "aggregate"]

      env = {
        NODE_ENV = "production"
      }

      secrets {
        secret_id   = docker_secret.job_database_uri.id
        secret_name = docker_secret.job_database_uri.name
        file_name   = "/var/secrets/database_uri"
      }

      secrets {
        secret_id   = docker_secret.database_ssl_certificate.id
        secret_name = docker_secret.database_ssl_certificate.name
        file_name   = "/var/secrets/database_ssl_certificate"
      }

      stop_grace_period = "5s"
    }

    force_update = 0
  }

  mode {
    replicated {
      replicas = 0
    }
  }

  lifecycle {
    create_before_destroy = false
  }
}
