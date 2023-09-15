resource "google_secret_manager_secret_iam_member" "aws-access-key-iam" {
  project   = google_secret_manager_secret.aws-access-key.project
  secret_id = google_secret_manager_secret.aws-access-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.k8s_secrets_email}"
}

resource "google_secret_manager_secret_iam_member" "aws-secret-access-key-iam" {
  project   = google_secret_manager_secret.aws-secret-access-key.project
  secret_id = google_secret_manager_secret.aws-secret-access-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.k8s_secrets_email}"
}

resource "google_secret_manager_secret_iam_member" "gcp-access-key-iam" {
  project   = google_secret_manager_secret.gcp-access-key.project
  secret_id = google_secret_manager_secret.gcp-access-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.k8s_secrets_email}"
}

resource "google_secret_manager_secret_iam_member" "gcp-secret-access-key-iam" {
  project   = google_secret_manager_secret.gcp-secret-access-key.project
  secret_id = google_secret_manager_secret.gcp-secret-access-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.k8s_secrets_email}"
}
