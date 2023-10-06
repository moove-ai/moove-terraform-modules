resource "google_secret_manager_secret" "vaisala_api_key" {
  project   = var.vaisala_api_key_secret_project
  secret_id = var.vaisala_api_key_secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "vaisala_api_key_secret_iam_member" {
  for_each  = var.environments
  project   = google_secret_manager_secret.vaisala_api_key.project
  secret_id = google_secret_manager_secret.vaisala_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.function_sa[each.key].email}"
}
