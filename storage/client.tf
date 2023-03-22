resource "google_service_account" "client" {
  count        = var.client_bucket ? 1 : 0
  project      = var.project_id
  account_id   = "moove-data-import-${var.client_id}-${lower(var.location)}"
  display_name = "${var.client_name} data import"
  description  = "Service account used for data import for ${var.client_name} (${var.client_id})"
}

resource "google_secret_manager_secret" "client-id" {
  count     = var.client_bucket ? 1 : 0
  project   = var.secret_project
  secret_id = "client-id_${var.client_name}"

  labels = {
    terraformed = "true"
    secret-data = "terraform"
    client      = var.client_name
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "client-id-version" {
  count       = var.client_bucket ? 1 : 0
  secret      = google_secret_manager_secret.client-id[0].id
  secret_data = var.client_id
}


resource "google_storage_hmac_key" "key" {
  count                 = var.client_hmac_key ? 1 : 0
  service_account_email = google_service_account.client[0].email
}

resource "google_secret_manager_secret" "client-hmac-key" {
  count     = var.client_hmac_key ? 1 : 0
  project   = var.secret_project
  secret_id = "client-key_${var.client_name}"

  labels = {
    terraformed = "true"
    secret-data = "terraform"
    client      = var.client_name
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "client-key-version" {
  count       = var.client_hmac_key ? 1 : 0
  secret      = google_secret_manager_secret.client-hmac-key[0].id
  secret_data = local.client-key
}

locals {
  client-key = <<-EOT
    ACCESS_KEY=${var.client_hmac_key ? google_storage_hmac_key.key[0].access_id : "null"}
    SECRET_ACCESS_KEY=${var.client_hmac_key ? google_storage_hmac_key[0].key.secret : "null"}
    EOT
}

resource "google_secret_manager_secret" "client-sa-key" {
  count     = var.client_sa_key ? 1 : 0
  project   = var.secret_project
  secret_id = "client-key_${var.client_name}"

  labels = {
    terraformed = "true"
    secret-data = "terraform"
    client      = var.client_name
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "client-sa-key-version" {
  count       = var.client_hmac_key ? 1 : 0
  secret      = google_secret_manager_secret.client-sa-key[0].id
  secret_data = local.client-key
}