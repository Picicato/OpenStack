terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.18.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Namespaces
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "dice_roller" {
  metadata {
    name = "dice-roller"
  }
}

# Prometheus/Grafana via Helm
resource "helm_release" "prometheus_stack" {
  name       = "monitoring-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "46.0.0"
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }
}

# Déploiement de l'API Dice Roller
resource "kubernetes_deployment" "dice_roller" {
  metadata {
    name      = "dice-roller"
    namespace = kubernetes_namespace.dice_roller.metadata[0].name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "dice-roller"
      }
    }
    template {
      metadata {
        labels = {
          app = "dice-roller"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8000"
          "prometheus.io/path"   = "/health"
        }
      }
      spec {
        container {
          image             = "dice-roller:latest"
          name              = "dice-roller"
          image_pull_policy = "Never"  # Force Kubernetes à utiliser l'image locale
          port {
            container_port = 8000
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

# Service pour exposer l'API Dice Roller
resource "kubernetes_service" "dice_roller" {
  metadata {
    name      = "dice-roller"
    namespace = kubernetes_namespace.dice_roller.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.dice_roller.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8000
    }
    type = "LoadBalancer"
  }
}
