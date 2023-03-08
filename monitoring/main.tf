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
    automatic = true
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
