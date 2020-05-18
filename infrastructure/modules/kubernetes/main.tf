locals {
  namespace = "thesemetrics"

  app_version   = "0.1.2"
  job_version   = "0.1.4"
  pixel_version = "0.1.2"

  labels = {
    app           = "TheseMetrics"
    pixel_service = "Pixel"
    app_service   = "App"
  }

  dockerconfigjson = {
    "auths" : {
      "docker.pkg.github.com" : {
        "username" : "znck",
        "password" : "${var.docker_registry_token}",
        "email" : "rahulkdn+deployer@gmail.com",
        "auth" : base64encode(join(":", ["_json_key", var.docker_registry_token]))
      }
    }
  }
}

resource "kubernetes_namespace" "default" {
  metadata {
    name = local.namespace
  }
}

// ------------------ Secrets -----------------------

resource "kubernetes_secret" "certificate" {
  metadata {
    namespace = local.namespace
    name      = "default-ssl-certificate"
  }

  data = {
    "tls.crt" = var.tls_certifacte
    "tls.key" = var.tls_private_key
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "docker" {
  metadata {
    namespace = local.namespace
    name      = "docker-credentials"
  }

  data = {
    ".dockerconfigjson" = jsonencode(local.dockerconfigjson)
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "database" {
  metadata {
    namespace = local.namespace
    name      = "databse"
  }

  data = {
    app   = var.app_database_uri
    pixel = var.pixel_database_uri
    job   = var.job_database_uri

    ca = var.db_certificate
  }
}

// ------------------- Jobs -------------------------

resource "kubernetes_job" "db_migrate" {
  metadata {
    name      = "db-migrate"
    namespace = local.namespace

    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade"
      "helm.sh/hook-delete-policy" = "hook-succeeded"
    }
  }

  spec {
    active_deadline_seconds = 60

    template {
      metadata {
        name = "db-migrate"
      }

      spec {
        restart_policy = "Never"

        container {
          name  = "db-migrate"
          image = "docker.pkg.github.com/znck/thesemetrics/db:${local.job_version}"

          env {
            name = "POSTGRES_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database.metadata[0].name
                key  = "job"
              }
            }
          }

          env {
            name = "POSTGRES_CERTIFICATE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database.metadata[0].name
                key  = "ca"
              }
            }
          }

          command = ["npm", "run", "aggregate"]
        }

        image_pull_secrets {
          name = kubernetes_secret.docker.metadata[0].name
        }
      }

    }
  }
}

resource "kubernetes_cron_job" "db_aggregate" {
  metadata {
    name      = "db-aggregate"
    namespace = local.namespace
  }

  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "5 0 * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    suspend                       = true

    job_template {
      metadata {
        name = "db-aggregate"
      }

      spec {
        template {
          metadata {}
          spec {
            container {
              name  = "db-aggregate"
              image = "docker.pkg.github.com/znck/thesemetrics/db:${local.job_version}"

              env {
                name = "POSTGRES_URL"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.database.metadata[0].name
                    key  = "job"
                  }
                }
              }

              env {
                name = "POSTGRES_CERTIFICATE"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.database.metadata[0].name
                    key  = "ca"
                  }
                }
              }

              command = ["npm", "run", "aggregate"]
            }

            image_pull_secrets {
              name = kubernetes_secret.docker.metadata[0].name
            }
          }
        }
      }

    }
  }
}

// ------------------- Deployments ------------------

resource "kubernetes_deployment" "pixel" {
  metadata {
    namespace     = local.namespace
    generate_name = "deployment-pixel-"
  }

  spec {
    replicas = var.pixel_replicas

    selector {
      match_labels = {
        app     = local.labels.app
        service = local.labels.pixel_service
      }
    }

    template {
      metadata {
        namespace = local.namespace
        name      = "deployment-template-pixel"
        labels = {
          app     = local.labels.app
          service = local.labels.pixel_service
        }
      }

      spec {
        container {
          name  = "pixel"
          image = "docker.pkg.github.com/znck/thesemetrics/pixel:${local.pixel_version}"

          port {
            container_port = 3001
          }

          env {
            name = "POSTGRES_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database.metadata[0].name
                key  = "pixel"
              }
            }
          }

          env {
            name = "POSTGRES_CERTIFICATE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database.metadata[0].name
                key  = "ca"
              }
            }
          }
        }

        image_pull_secrets {
          name = kubernetes_secret.docker.metadata[0].name
        }
      }
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    namespace     = local.namespace
    generate_name = "deployment-app-"
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app     = local.labels.app
        service = local.labels.app_service
      }
    }

    template {
      metadata {
        namespace = local.namespace
        name      = "deployment-template-app"

        labels = {
          app     = local.labels.app
          service = local.labels.app_service
        }
      }

      spec {
        container {
          name  = "app"
          image = "docker.pkg.github.com/znck/thesemetrics/app:${local.app_version}"

          port {
            container_port = 3000
          }

          env {
            name = "POSTGRES_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database.metadata[0].name
                key  = "app"
              }
            }
          }

          env {
            name = "POSTGRES_CERTIFICATE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database.metadata[0].name
                key  = "ca"
              }
            }
          }
        }

        image_pull_secrets {
          name = kubernetes_secret.docker.metadata[0].name
        }
      }
    }
  }
}

// -------------------- Services --------------------

resource "kubernetes_service" "pixel" {
  metadata {
    namespace = local.namespace
    name      = "service-pixel"
  }

  spec {
    selector = {
      app     = local.labels.app
      service = local.labels.pixel_service
    }

    session_affinity = "None"

    port {
      port        = 80
      target_port = 3001
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    namespace = local.namespace
    name      = "service-app"
  }

  spec {
    selector = {
      app     = local.labels.app
      service = local.labels.app_service
    }

    session_affinity = "None"

    port {
      port        = 80
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress" "default" {
  metadata {
    namespace = local.namespace
    name      = "ingress-default"

    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
    }
  }

  spec {

    backend {
      service_name = kubernetes_service.app.metadata[0].name
      service_port = 80
    }

    rule {
      http {
        path {
          backend {
            service_name = kubernetes_service.pixel.metadata[0].name
            service_port = 80
          }

          path = "/*.gif"
        }
      }
    }

    tls {
      secret_name = kubernetes_secret.certificate.metadata[0].name
    }
  }
}
