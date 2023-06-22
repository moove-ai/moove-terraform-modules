resource "google_service_account" "k8s-secrets" {
  project      = var.project_id
  account_id   = "k8s-secrets"
  display_name = "Kubernetes Secrets"
  description  = "Service account used by the external-secrets k8s app."
}

resource "google_project_iam_member" "external-secrets-accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.k8s-secrets.email}"
}

resource "google_project_iam_member" "external-secrets-secret-accessor" {
  project = "moove-secrets"
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.k8s-secrets.email}"
}

resource "google_project_iam_member" "external-secrets-viewer" {
  project = var.project_id
  role    = "roles/secretmanager.viewer"
  member  = "serviceAccount:${google_service_account.k8s-secrets.email}"
}

resource "google_service_account_iam_member" "k8s-secrets-workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/k8s-secrets]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-secrets.name
}
