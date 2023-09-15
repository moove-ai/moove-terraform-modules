locals {
  auth_example = <<EOT
  {
    "username": "default",
    "password": "moove123111"
  }
  EOT
}

data "google_service_account" "sa" {
  for_each   = var.environments
  project    = each.value.project_id
  account_id = each.value.service_account_name
}


resource "google_storage_bucket" "bucket" {
  for_each = { for env, config in var.environments : env => config if config.create_bucket }
  name     = each.value.bucket_name
  location = each.value.bucket_location
  project  = each.value.project_id
}

resource "google_storage_bucket_iam_member" "bucket_iam_member" {
  for_each   = var.environments
  bucket     = each.value.bucket_name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${data.google_service_account.sa[each.key].email}"
  depends_on = [google_storage_bucket.bucket]
}

resource "google_secret_manager_secret" "auth" {
  for_each  = var.environments
  project   = each.value.project_id
  secret_id = var.auth_secret_id

  labels = {
    function    = "gcs-proxy"
    environment = each.key
    bucket      = each.value.bucket_name
    terraformed = "true"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "auth-example" {
  for_each    = var.environments
  secret      = google_secret_manager_secret.auth[each.key].id
  secret_data = local.auth_example
}
