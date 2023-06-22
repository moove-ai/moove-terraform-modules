resource "google_service_account" "object-store-sa" {
  account_id = "k7s-thanos"
  project    = var.project_id
}

resource "google_service_account_key" "object-store-key" {
  service_account_id = google_service_account.object-store-sa.name
}

resource "google_storage_bucket" "thanos-object-store" {
  project  = var.project_id
  location = "US"
  name     = "moove-${var.cluster_name}-metric-store"
}

resource "google_secret_manager_secret" "thanos-object-store-config" {
  project   = var.project_id
  secret_id = "thanos-object-store-config"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "thanos-object-store-config" {
  secret      = google_secret_manager_secret.thanos-object-store-config.id
  secret_data = local.object_store_config
}

resource "google_storage_bucket_iam_member" "thanos-object-store-iam" {
  bucket = google_storage_bucket.thanos-object-store.name
  member = "serviceAccount:${google_service_account.object-store-sa.email}"
  role   = "roles/storage.objectAdmin"
}

locals {
  object_store_config = <<-EOT
  type: GCS
  config:
    bucket: "${google_storage_bucket.thanos-object-store.name}"
    service_account: |-
      ${indent(3, base64decode(google_service_account_key.object-store-key.private_key))}
  EOT
}
