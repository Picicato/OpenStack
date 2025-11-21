output "service_url" {
  value = kubernetes_service.vuln_app.metadata[0].name
}
