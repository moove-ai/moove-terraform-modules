resource "google_service_account" "service-account" {
  project      = var.project_id
  account_id   = var.account_id
  description  = var.description
  display_name = var.display_name
}
