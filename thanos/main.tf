resource "google_service_account" "k8s-prometheus" {
  project = var.project_id
  account_id = "k8s-prometheus"
}

resource "google_service_account_key" "k8s-prometheus" {
  service_account_id = google_service_account.k8s-prometheus.name
}

resource "google_storage_bucket" "persistence-prometheus-object-store" {
  project  = var.project_id
  location = "US"
  name     = "moove-prometheus-storage"

  labels = {
    environment = "mgmt"
    app    = "monitoring"
    function = "metric-store"
    client      = "moove"
    terraformed = "true"
    project     = var.project_id
  }
}

resource "google_secret_manager_secret" "thanos-object-store-config" {
  project   = var.project_id
  secret_id = "monitoring_thanos_storage-config"
  replication {
    automatic = true
  }

  labels = {
    environment = "mgmt"
    function    = "monitoring"
    client      = "moove"
    terraformed = "true"
    secret-data = "terraformed"
  }
}

resource "google_secret_manager_secret_version" "thanos-object-store-config" {
  secret      = google_secret_manager_secret.thanos-object-store-config.id
  secret_data = local.object_store_config
}

resource "google_storage_bucket_iam_member" "thanos-object-store-iam" {
  bucket = google_storage_bucket.persistence-prometheus-object-store.name
  member = "serviceAccount:${google_service_account.k8s-prometheus.email}"
  role   = "roles/storage.objectAdmin"
}

locals {
  object_store_config = <<-EOT
  type: GCS
  config:
    bucket: "${google_storage_bucket.persistence-prometheus-object-store.name}"
    service_account: |-
      ${indent(4, base64decode(google_service_account_key.k8s-prometheus.private_key))}
  EOT
}
