resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

output "name" {
  value = kubernetes_namespace.ns.metadata[0].name
}
