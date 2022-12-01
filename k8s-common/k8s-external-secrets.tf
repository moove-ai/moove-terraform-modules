resource "google_service_account" "k8s-secrets" {
  count        = var.install_external_secrets ? 1 : 0
  project      = var.project_id
  account_id   = "k8s-secrets"
  display_name = "Kubernetes Secrets"
  description  = "Service account used by the external-secrets k8s app."
}

resource "google_project_iam_member" "external-secrets-accessor" {
  count   = var.install_external_secrets ? 1 : 0
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.k8s-secrets[0].email}"
}

resource "google_project_iam_member" "external-secrets-secret-accessor" {
  count   = var.install_external_secrets ? 1 : 0
  project = "moove-secrets"
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.k8s-secrets[0].email}"
}

resource "google_project_iam_member" "external-secrets-viewer" {
  count   = var.install_external_secrets ? 1 : 0
  project = var.project_id
  role    = "roles/secretmanager.viewer"
  member  = "serviceAccount:${google_service_account.k8s-secrets[0].email}"
}

resource "google_service_account_iam_member" "k8s-secrets-workload-identity" {
  count              = var.install_external_secrets ? 1 : 0
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/k8s-secrets]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-secrets[0].name
}
