resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = "k8s-egress-wejo-api"
  display_name = "egress-omnitracs-wejo-api-us"
  description  = "Service account for the  egress-omnitracs-wejo-api-us k8s application"
}

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

resource "google_service_account_iam_member" "workload-identity" {
  member             = "serviceAccount:${var.k8s_cluster_project}.svc.id.goog[${var.k8s_namespace}/egress-omnitracs-wejo-api-us]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.sa.name
}
