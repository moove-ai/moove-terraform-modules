resource "google_service_account" "service-account" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "scoring"
  description  = "Used for the scoring application."
}


resource "google_secret_manager_secret_iam_member" "scoring-config" {
  project   = var.project_id
  secret_id = "scoring-api-config"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service-account.email}"
}
