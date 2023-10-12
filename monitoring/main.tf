resource "google_service_account" "k8s-grafana" {
  account_id   = "k8s-grafana"
  display_name = "Grfana"
  description  = "Service account used for the the persistent monitoring grafana application"
  project      = var.project_id
}

resource "google_service_account_iam_member" "workload-identity" {
  for_each           = toset(var.regions)
  member             = "serviceAccount:${var.cluster_project_id}.svc.id.goog[systems/monitoring-prometheus-mgmt-${each.key}-grafana]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-grafana.name
}

resource "google_project_iam_member" "k8s-grafana-iam-bq" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.k8s-grafana.email}"
}

resource "google_project_iam_member" "k8s-grafana-iam-monitoring" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.k8s-grafana.email}"
}

resource "google_service_account" "k8s-thanos" {
  account_id   = "k8s-thanos"
  display_name = "Monitoring"
  description  = "Service account used for the the persistent monitoring application"
  project      = var.project_id
}

resource "google_service_account_key" "k8s-thanos" {
  service_account_id = google_service_account.k8s-thanos.name
}

resource "google_storage_bucket" "thanos-prometheus-object-store" {
  project  = var.project_id
  location = "US"
  name     = "moove-metrics-storage"

  labels = {
    environment = "mgmt"
    app         = "monitoring"
    function    = "metric-store"
    client      = "moove"
    terraformed = "true"
    project     = var.project_id
  }
}

resource "google_secret_manager_secret" "thanos-object-store-config" {
  project   = "moove-secrets"
  secret_id = "thanos-object-store-config"

  labels = {
    environment = "mgmt"
    function    = "monitoring"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "thanos-object-store-config" {
  secret      = google_secret_manager_secret.thanos-object-store-config.id
  secret_data = local.object_store_config
}

locals {
  object_store_config = <<-EOT
  type: GCS
  config:
    bucket: "${google_storage_bucket.thanos-prometheus-object-store.name}"
    service_account: |-
      ${indent(4, base64decode(google_service_account_key.k8s-thanos.private_key))}
  EOT
}
