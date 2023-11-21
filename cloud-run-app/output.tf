#output "service_account_emails" {
#  value = values(google_service_account.runner)[*].email
#}

output "service_account_name" {
  value = var.service_account_id != "" ? var.service_account_id : var.application_name
}

output "service_account_email" {
  value = google_service_account.runner.email
}

output "service_account_member" {
  value = google_service_account.runner.member
}

output "project" {
  value = var.project_id
}
