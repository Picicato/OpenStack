terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
  }
  required_version = "~> 1.13.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}