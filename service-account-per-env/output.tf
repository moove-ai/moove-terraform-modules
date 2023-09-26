output "account_id" {
  value       = var.account_id
  description = "The account id of the service account."
}

output "service_account_emails" {
  value       = { for env, sa in google_service_account.service-account : env => sa.email }
  description = "Map of service account emails created for each environment."
}

output "service_account_ids" {
  value       = { for env, sa in google_service_account.service-account : env => sa.id }
  description = "Map of service account ids created for each environment."
}

output "service_account_projects" {
  value       = { for env, sa in google_service_account.service-account : env => sa.project }
  description = "Map of service account projects created for each environment."
}

output "service_account_project_ids" {
  value       = { for env, sa in google_service_account.service-account : env => sa.project }
  description = "Map of service account emails created for each environment."
}