output "node_service_account_email" {
  value = google_service_account.k8s-nodes.email
}
