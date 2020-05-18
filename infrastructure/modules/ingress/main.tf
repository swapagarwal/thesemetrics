resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "ingress-nignx"

    labels = {
      "app.kubernetes.io/name"     = "ingress-nignx"
      "app.kubernetes.io/instance" = "ingress-nignx"
    }
  }
}

locals {
  namespace = kubernetes_namespace.nginx.metadata[0].name

  ingress    = "ingress-nignx"
  admission  = "ingress-nginx-admission"
  controller = "ingress-nginx-controller"
}

resource "kubernetes_service_account" "nginx" {
  metadata {
    name      = local.ingress
    namespace = local.namespace
    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "controller"
    }
  }
}

resource "kubernetes_config_map" "nginx" {
  metadata {
    name      = local.controller
    namespace = local.namespace
    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "controller"
    }
  }
  data = {
    use-proxy-protocol = "true"
  }
}

resource "kubernetes_cluster_role" "nginx" {
  metadata {
    name = local.controller

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }

  rule {
    api_groups = [""]
    verbs      = ["list", "watch"]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets"]
  }

  rule {
    api_groups = [""]
    verbs      = ["get"]
    resources  = ["nodes"]
  }

  rule {
    api_groups = [""]
    verbs      = ["get", "list", "update", "watch"]
    resources  = ["services"]
  }

  rule {
    api_groups = [""]
    verbs      = ["create", "patch"]
    resources  = ["events"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    verbs      = ["get", "list", "watch"]
    resources  = ["ingresses"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    verbs      = ["update"]
    resources  = ["ingresses/status"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    verbs      = ["get", "list", "watch"]
    resources  = ["ingressclasses"]
  }
}

resource "kubernetes_cluster_role_binding" "nginx" {
  metadata {
    name = local.ingress
    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.ingress
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.ingress
    namespace = local.namespace
  }
}

resource "kubernetes_role" "nginx" {
  metadata {
    name      = local.ingress
    namespace = local.namespace
    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "controller"
    }
  }

  rule {
    api_groups = [""]
    verbs      = ["get"]
    resources  = ["namespaces"]
  }

  rule {
    api_groups = [""]
    verbs      = ["get", "list", "watch"]
    resources  = ["configmaps", "pods", "secrets", "endpoints"]
  }

  rule {
    api_groups = [""]
    verbs      = ["get", "list", "update", "watch"]
    resources  = ["services"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    verbs      = ["get", "list", "watch"]
    resources  = ["ingresses"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    verbs      = ["update"]
    resources  = ["ingresses/status"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    verbs      = ["get", "list", "watch"]
    resources  = ["ingressclasses"]
  }

  rule {
    api_groups = [""]
    verbs      = ["create"]
    resources  = ["configmaps"]
  }

  rule {
    api_groups = [""]
    verbs      = ["create", "get", "update"]
    resources  = ["endpoints"]
  }

  rule {
    api_groups = [""]
    verbs      = ["create", "patch"]
    resources  = ["events"]
  }
}

resource "kubernetes_role_binding" "nginx" {
  metadata {
    name      = local.ingress
    namespace = local.namespace
    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "controller"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.ingress
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.ingress
    namespace = local.namespace
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "ingress-nginx-contoller-admission"
    namespace = local.namespace
    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/controller" = "controller"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "https-webhook"
      port        = 443
      target_port = "webhook"
    }

    selector = {
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/controller" = "controller"
    }
  }
}

resource "kubernetes_service" "controller" {
  metadata {
    name      = local.controller
    namespace = local.namespace
    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/controller" = "controller"
    }
    annotations = {
      "service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol" = "true"
    }
  }

  spec {
    type = "LoadBalancer"

    external_traffic_policy = "Local"

    port {
      name     = "http"
      port     = 80
      protocol = "TCP"

      target_port = "http"
    }

    port {
      name     = "https"
      port     = 443
      protocol = "TCP"

      target_port = "https"
    }

    selector = {
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/controller" = "controller"
    }
  }
}

resource "kubernetes_deployment" "controller_depolyment" {
  metadata {
    name      = local.controller
    namespace = local.namespace

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/controller" = "controller"
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name"       = local.ingress
        "app.kubernetes.io/instance"   = local.ingress
        "app.kubernetes.io/controller" = "controller"
      }
    }
    revision_history_limit = 10
    min_ready_seconds      = 0

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"       = local.ingress
          "app.kubernetes.io/instance"   = local.ingress
          "app.kubernetes.io/controller" = "controller"
        }
      }

      spec {
        dns_policy = "ClusterFirst"
        container {
          name              = "controller"
          image             = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.32.0"
          image_pull_policy = "IfNotPreset"
          lifecycle {
            pre_stop {
              exec {
                command = ["/wait-shutdown"]
              }
            }
          }
          args = [
            "/nginx-ingress-controller",
            "--publish-service=ingress-nginx/ingress-nginx-controller",
            "--election-id=ingress-controller-leader",
            "--ingress-class=nginx",
            "--configmap=ingress-nginx/ingress-nginx-controller",
            "--validating-webhook=:8443",
            "--validating-webhook-certificate=/usr/local/certificates/cert",
            "--validating-webhook-key=/usr/local/certificates/key",
          ]

          security_context {
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
            run_as_user                = 101
            allow_privilege_escalation = true
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          liveness_probe {
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds        = 10

            timeout_seconds   = 1
            success_threshold = 1
            failure_threshold = 3
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds        = 10

            timeout_seconds   = 1
            success_threshold = 1
            failure_threshold = 3

          }

          volume_mount {
            name       = "webhook-cer"
            mount_path = "/usr/local/certificates/"
            read_only  = true
          }

          resources {
            requests {
              cpu    = "100m"
              memory = "90Mi"
            }
          }
        }
        service_account_name             = local.ingress
        termination_grace_period_seconds = 300

        volume {
          name = "webhook-cert"
          secret {
            secret_name = local.admission
          }
        }
      }
    }
  }
}

resource "kubernetes_validating_webhook_configuration" "admission" {
  metadata {
    name = local.admission

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "admission-webhook"
    }
  }

  webhook {
    name = "validate.nginx.ingress.kubernetes.io"

    rule {
      api_groups   = ["extension", "networking.k8s.io"]
      api_versions = ["v1beta1"]
      operations   = ["CREATE", "UPDATE"]
      resources    = ["ingresses"]
    }

    failure_policy = "Fail"
    client_config {
      service {
        namespace = local.namespace
        name      = "ingress-nginx-controller-admission"
        path      = "/extensions/v1beta1/ingresses"
      }
    }
  }
}

resource "kubernetes_cluster_role" "admission" {
  metadata {
    name = local.admission

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "addmission-webhook"
    }

    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  rule {
    api_groups = ["admissionregistration.k8s.io"]
    verbs      = ["get", "update"]
    resources  = ["validatingwebhookconfgurations"]
  }
}

resource "kubernetes_cluster_role_binding" "admission" {
  metadata {
    name = local.admission

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "addmission-webhook"
    }

    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.admission
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.admission
    namespace = local.namespace
  }
}

resource "kubernetes_job" "create_admission" {
  metadata {
    name = "ingress-nginx-admission-create"
    namespace = local.namespace

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "addmission-webhook"
    }

    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  spec {
    template {
      metadata {
        name = "ingress-nginx-admission-create"

        labels = {
          "helm.sh/chart"                = "ingress-nginx-2.0.3"
          "app.kubernetes.io/name"       = local.ingress
          "app.kubernetes.io/instance"   = local.ingress
          "app.kubernetes.io/version"    = "0.32.0"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/component"  = "addmission-webhook"
        }
      }

      spec {
        container {
          name              = "create"
          image             = "jettech/kube-webhook-certgen:v1.2.0"
          image_pull_policy = "IfNotPresent"

          args = [
            "create",
            "--host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.ingress-nginx.svc",
            "--namespace=ingress-nginx",
            "--secret-name=ingress-nginx-admission",
          ]
        }

        restart_policy = "OnFailure"

        service_account_name = local.admission

        security_context {
          run_as_non_root = true
          run_as_user     = 2000
        }
      }
    }
  }
}

resource "kubernetes_job" "patch_admission" {
  metadata {
    name = "ingress-nginx-admission-patch"
    namespace = local.namespace

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "addmission-webhook"
    }

    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  spec {
    template {
      metadata {
        name = "ingress-nginx-admission-patch"

        labels = {
          "helm.sh/chart"                = "ingress-nginx-2.0.3"
          "app.kubernetes.io/name"       = local.ingress
          "app.kubernetes.io/instance"   = local.ingress
          "app.kubernetes.io/version"    = "0.32.0"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/component"  = "addmission-webhook"
        }
      }

      spec {
        container {
          name              = "patch"
          image             = "jettech/kube-webhook-certgen:v1.2.0"
          image_pull_policy = "IfNotPresent"
          args = [
            "patch",
            "--webhook-name=ingress-nginx-admission",
            "--namespace=ingress-nginx",
            "--patch-mutating=false",
            "--secret-name=ingress-nginx-admission",
            "--patch-failure-policy=Fail",
          ]
        }

        restart_policy       = "OnFailure"
        service_account_name = local.admission
        security_context {
          run_as_non_root = true
          run_as_user     = 2000
        }
      }
    }
  }
}

resource "kubernetes_role" "admission" {
  metadata {
    name = local.admission
    namespace = local.namespace

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "addmission-webhook"
    }

    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_role_binding" "admission" {
  metadata {
    name      = local.admission
    namespace = local.namespace

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "addmission-webhook"
    }

    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.admission
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.admission
    namespace = local.namespace
  }
}

resource "kubernetes_service_account" "admission" {
  metadata {
    name      = local.admission
    namespace = local.namespace

    labels = {
      "helm.sh/chart"                = "ingress-nginx-2.0.3"
      "app.kubernetes.io/name"       = local.ingress
      "app.kubernetes.io/instance"   = local.ingress
      "app.kubernetes.io/version"    = "0.32.0"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/component"  = "addmission-webhook"
    }

    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
  }
}
