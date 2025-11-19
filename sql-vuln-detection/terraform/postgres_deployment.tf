resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15-alpine"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_DB"
            value = "test"
          }

          env {
            name  = "POSTGRES_USER"
            value = "test"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "test"
          }

          volume_mount {
            name       = "pgdata"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "init-sql"
          config_map {
            name = kubernetes_config_map.pg_init.metadata[0].name
          }
        }

        volume {
          name = "pgdata"
          empty_dir {}
        }
      }
    }
  }
}   