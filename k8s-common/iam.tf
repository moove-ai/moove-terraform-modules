## k8s tooling IAM
# k8s-secrets
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

# DNS Admin Service Account
data "google_service_account" "dns-admin" {
  count      = var.install_external_dns ? 1 : 0
  account_id = "dns-admin"
  project    = "moove-systems"
}

resource "google_service_account_iam_member" "dns-admin-data-pipelines-workload-identity" {
  count              = var.install_external_dns ? 1 : 0
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/external-dns]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = data.google_service_account.dns-admin[0].name
}

# Keda
resource "google_service_account" "k8s-keda" {
  count        = var.install_keda ? 1 : 0
  project      = var.project_id
  account_id   = "k8s-keda"
  display_name = "Keda Autoscaler (Kubernetes)"
  description  = "Service account used by Keda. 'keda-operator'"
}

resource "google_service_account_iam_member" "k8s-keda-workload-identity" {
  count              = var.install_keda ? 1 : 0
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/keda-operator]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-keda[0].name
}

resource "google_project_iam_member" "k8s-keda-monitoring-iam" {
  count   = var.install_keda ? 1 : 0
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.k8s-keda[0].email}"
}
