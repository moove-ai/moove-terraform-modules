#output "service_account_emails" {
#  value = values(google_service_account.runner)[*].email
#}

output "service_account_name" {
  value = var.service_account_id != "" ? var.service_account_id : var.application_name
}

output "service_account_emails" {
  value = { for env, sa in google_service_account.runner : env => sa.email }
}

output "projects" {
  value = { for env, config in var.environments : config.project_id => env }
}
