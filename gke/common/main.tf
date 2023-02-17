/**
 * # gke
 *
 * creates iam resources associated with an environment. This only needs to be applied once per environment (staging, production, etc) 
 *
 * 
 * Written by Alex Merenda for moove.ai
 */
# gke/iam.tf

## k8s nodes IAM
## The service account running the k8s nodes
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

resource "google_project_iam_member" "network-host-service-agent" {
  project = var.cluster_network_project_id
  role    = "roles/container.hostServiceAgentUser"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = var.project_id
}
