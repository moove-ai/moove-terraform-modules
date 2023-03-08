data "google_service_account" "k8s-thanos" {
  project    = var.project_id
  account_id = "k8s-thanos"
}

resource "google_service_account_key" "k8s-thanos" {
  service_account_id = data.google_service_account.k8s-thanos.name
}

resource "google_storage_bucket" "thanos-object-store" {
  project  = var.project_id
  location = "US"
  name     = "moove-${var.environment}-${var.region}-metric-store"
}

resource "google_secret_manager_secret" "thanos-object-store-config" {
  project   = var.project_id
  secret_id = "thanos-${var.region}-object-store-config"
  replication {
    automatic = true
  }

  labels = {
    environment = "mgmt"
    function    = "monitoring"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }
}

resource "google_secret_manager_secret_version" "thanos-object-store-config" {
  secret      = google_secret_manager_secret.thanos-object-store-config.id
  secret_data = local.object_store_config
}

resource "google_storage_bucket_iam_member" "thanos-object-store-iam" {
  bucket = google_storage_bucket.thanos-object-store.name
  member = "serviceAccount:${data.google_service_account.k8s-thanos.email}"
  role   = "roles/storage.objectAdmin"
}

locals {
  object_store_config = <<-EOT
  type: GCS
  config:
    bucket: "${google_storage_bucket.thanos-object-store.name}"
    service_account: |-
      ${indent(4, base64decode(google_service_account_key.k8s-thanos.private_key))}
  EOT
}
