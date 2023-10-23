output "service_account_id" {
  value       = var.create_service_account ? google_service_account.service_account[0].id : data.google_service_account.service_account[0].id
  description = "The service account ID"
}

output "service_account_member" {
  value       = var.create_service_account ? google_service_account.service_account[0].member : data.google_service_account.service_account[0].member
  description = "The service account member. Format: 'service_account:email'"
  depends_on  = []
}

output "service_account_name" {
  value       = var.create_service_account ? google_service_account.service_account[0].name : data.google_service_account.service_account[0].name
  description = "The name of the service account"
  depends_on  = []
}
