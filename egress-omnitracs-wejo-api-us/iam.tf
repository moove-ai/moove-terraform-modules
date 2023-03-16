resource "google_secret_manager_secret_iam_member" "access-iam" {
  project   = google_secret_manager_secret.access.project
  secret_id = google_secret_manager_secret.access.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.k8s_secrets_email}"
}

resource "google_secret_manager_secret_iam_member" "secret-iam" {
  project   = google_secret_manager_secret.secret.project
  secret_id = google_secret_manager_secret.secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.k8s_secrets_email}"
}
