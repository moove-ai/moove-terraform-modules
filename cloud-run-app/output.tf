output "service_account_email" {
  value = var.create_service_account ? google_service_account.runner[0].email : data.google_service_account.runner[0].email

}

output "service_account_id" {
  value = var.create_service_account ? google_service_account.runner[0].id : data.google_service_account.runner[0].id
}

output "service_account_name" {
  value = var.create_service_account ? google_service_account.runner[0].name : data.google_service_account.runner[0].name
}
