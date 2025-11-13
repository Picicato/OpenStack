output "grafana_admin_password" {
  value = var.grafana_password
}

output "grafana_portforward_command" {
  value = "minikube kubectl -- port-forward -n monitoring svc/monitoring-stack-grafana 3000:80 &"
}

output "dice_roller_service_ip" {
  value = kubernetes_service.dice_roller.status[0].load_balancer[0].ingress[0].ip
}

output "dice_roller_service_port" {
  value = kubernetes_service.dice_roller.spec[0].port[0].port
}
