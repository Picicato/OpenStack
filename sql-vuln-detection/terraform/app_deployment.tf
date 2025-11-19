resource "kubernetes_deployment" "vuln_app" {
  metadata {
    name      = "vuln-app"
    namespace = var.namespace
    labels = {
      app = "vuln-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vuln-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "vuln-app"
        }
      }

      spec {
        container {
          name              = "vuln-app"
          image             = "vuln-app:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 5000
          }

          env {
            name  = "PG_HOST"
            value = "postgres"
          }

          env {
            name  = "PG_DB"
            value = "test"
          }

          env {
            name  = "PG_USER"
            value = "test"
          }

          env {
            name  = "PG_PASS"
            value = "test"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "vuln_app" {
  metadata {
    name      = "vuln-app"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "vuln-app"
    }

    port {
      port        = 80
      target_port = 5000
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}

