output "name" {
  value       = google_service_account.sa.name
  description = "The serivce account name"
}

output "email" {
  value       = google_service_account.sa.email
  description = "The serivce account email"
}

output "project_id" {
  value       = google_service_account.sa.project
  description = "The serivce account email"
}