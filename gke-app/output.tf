output "service_account_id" {
  service_account_id = var.create_serviceaccount ? google_service_account.serviceaccount[0].id : data.google_service_account.my_service_account.id
  description        = "The service account ID"
  depends_on         = []
}

output "service_account_member" {
  service_account_id = var.create_serviceaccount ? google_service_account.serviceaccount[0].member : data.google_service_account.my_service_account.member
  description        = "The service account member. Format: 'serviceAccount:email'"
  depends_on         = []
}

output "service_account_name" {
  service_account_id = var.create_serviceaccount ? google_service_account.serviceaccount[0].name : data.google_service_account.my_service_account.name
  description        = "The name of the service account"
  depends_on         = []
}
