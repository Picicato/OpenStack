output "service_name" {
  value = kubernetes_service.sqli_detector.metadata[0].name
}

output "deployment_name" {
  value = kubernetes_deployment.sqli_detector.metadata[0].name
}
