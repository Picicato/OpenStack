resource "kubernetes_config_map" "pg_init" {
  metadata {
    name      = "postgres-init-sql"
    namespace = var.namespace
  }
  data = {
    "init.sql" = <<EOF
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            username TEXT,
            password TEXT
        );

        INSERT INTO users (username, password) VALUES ('admin', 'admin123');
    EOF
  }
}