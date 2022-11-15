output "service_account" {
  value       = google_service_account.atlantis.email
  sensitive   = false
  description = "The email address of the atlantis SA"
}

output "k8s_service_account" {
  value       = var.k8s_sa_name
  sensitive   = false
  description = "The kubernetes service account used by Atlantis"
}

output "namespace" {
  value       = var.namespace
  sensitive   = false
  description = "The kubernetes namespace Atlantis is running in"
}

output "app_name" {
  value       = var.app_name
  sensitive   = false
  description = "The name of application"
}
