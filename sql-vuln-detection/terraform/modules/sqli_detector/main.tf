resource "kubernetes_deployment" "sqli_detector" {
  metadata {
    name      = "sqli-detector"
    namespace = var.namespace
    labels = {
      app = "sqli-detector"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "sqli-detector"
      }
    }

    template {
      metadata {
        labels = {
          app = "sqli-detector"
        }
      }

      spec {
        container {
          name              = "sqli-detector"
          image             = "sqli-detector:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "sqli_detector" {
  metadata {
    name      = "sqli-detector"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "sqli-detector"
    }
    port {
      port        = 8000
      target_port = 8000
    }
    type = "ClusterIP"
  }
}
