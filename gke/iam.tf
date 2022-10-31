# gke/iam.tf

## k8s nodes IAM
# The service account running the k8s nodes
resource "google_service_account" "k8s-nodes" {
  project      = var.project_id
  account_id   = "k8s-nodes"
  display_name = "Kubernetes Nodes"
  description  = "The Service Account used by the Kubernetes Nodes"
}

# Least Privilege for the k8s nodes service account
resource "google_project_iam_member" "network" {
  project = var.cluster_network_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.k8s-nodes.email}"
}

resource "google_project_iam_member" "registry-reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.k8s-nodes.email}"
}

resource "google_project_iam_member" "storage-reader" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.k8s-nodes.email}"
}

resource "google_project_iam_member" "log-writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.k8s-nodes.email}"
}

resource "google_project_iam_member" "monitoring-viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.k8s-nodes.email}"
}

resource "google_project_iam_member" "metric-writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.k8s-nodes.email}"
}

resource "google_project_iam_member" "resource-metadata-writer" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.k8s-nodes.email}"
}

resource "google_project_iam_member" "network-container-service-agent" {
  project = var.cluster_network_project_id
  role    = "roles/containerregistry.ServiceAgent"
  member  = "serviceAccount:${google_service_account.k8s-nodes.email}"
}

## k8s tooling IAM
# k8s-secrets
resource "google_service_account" "k8s-secrets" {
  project      = var.project_id
  account_id   = "k8s-secrets"
  display_name = "Kubernetes Secrets"
  description  = "Service account used by the external-secrets k8s app."
}

resource "google_project_iam_member" "external-secrets-accessor" {
  project = var.cluster_network_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.k8s-secrets.email}"
}

resource "google_project_iam_member" "external-secrets-viewer" {
  project = var.cluster_network_project_id
  role    = "roles/secretmanager.viewer"
  member  = "serviceAccount:${google_service_account.k8s-secrets.email}"
}

resource "google_service_account_iam_member" "k8s-secrets-workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/k8s-secrets]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-secrets.name
  depends_on = [module.gke]
}

# DNS Admin Service Account
data "google_service_account" "dns-admin" {
  account_id = "dns-admin"
  project    = "moove-systems"
}

resource "google_service_account_iam_member" "dns-admin-data-pipelines-workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/external-dns]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = data.google_service_account.dns-admin.name
  depends_on = [module.gke]
}
