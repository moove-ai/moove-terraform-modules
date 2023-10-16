locals {
  auth_example = <<EOT
  {
    "username": "default",
    "password": "moove123111"
  }
  EOT
}

resource "google_service_account" "sa_create" {
  count        = var.create_service_account ? 1 : 0
  account_id   = var.service_account_name
  display_name = "Service account for GCS proxy"
  project      = var.project_id
}

data "google_service_account" "sa_data" {
  count      = var.create_service_account ? 0 : 1
  project    = var.project_id
  account_id = var.service_account_name
}

locals {
  sa_member = var.create_service_account ? google_service_account.sa_create[0].member : data.google_service_account.sa_data[0].member
}

resource "google_storage_bucket" "bucket" {
  count         = var.create_bucket ? 1 : 0
  name          = var.bucket_name
  location      = var.bucket_location
  project       = var.project_id
  force_destroy = var.bucket_force_destroy
}

resource "google_storage_bucket_iam_member" "bucket_iam_member" {
  bucket = var.bucket_name
  role   = "roles/storage.objectAdmin"
  member = local.sa_member
}

resource "google_secret_manager_secret" "auth" {
  project   = var.project_id
  secret_id = var.auth_secret_id

  labels = {
    function    = "gcs-proxy"
    environment = "default" # Assuming a default environment label, adjust as needed
    bucket      = var.bucket_name
    terraformed = "true"
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "auth-example" {
  secret      = google_secret_manager_secret.auth.id
  secret_data = local.auth_example
}

resource "google_secret_manager_secret_iam_member" "secret_iam_member" {
  secret_id = google_secret_manager_secret.auth.id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.sa_member
}
