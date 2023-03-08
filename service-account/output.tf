output "account_id" {
  value       = google_service_account.service-account.account_id
  sensitive   = false
  description = "The account ID of the service accoutn"
}

output "email" {
  value       = google_service_account.service-account.email
  sensitive   = false
  description = "The account ID of the service accoutn"
}

output "project_id" {
  value       = google_service_account.service-account.account_id
  sensitive   = false
  description = "The project id of the service accoutn"
}