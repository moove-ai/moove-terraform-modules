resource "google_service_account" "service-account" {
  for_each     = var.environments
  project      = each.value.project_id
  account_id   = var.account_id
  description  = var.description
  display_name = var.display_name
}
