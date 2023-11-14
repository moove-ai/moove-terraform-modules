output "account_id" {
  value       = google_service_account.service-account.account_id
  sensitive   = false
  description = "The account ID of the service account"
}

output "email" {
  value       = google_service_account.service-account.email
  sensitive   = false
  description = "The account ID of the service account"
}

output "id" {
  value       = google_service_account.service-account.id
  sensitive   = false
  description = "The account ID of the service account"
}

output "name" {
  value       = google_service_account.service-account.name
  sensitive   = false
  description = "The name of the service account"
}
