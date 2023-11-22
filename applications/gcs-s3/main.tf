resource "random_string" "postfix" {
  length  = 6
  special = false
}

resource "google_service_account" "sa" {
  account_id   = "moove-data-import-${random_string.postfix.id}"
  display_name = "Service Account for ${var.client_name}"
}

resource "google_secret_manager_secret" "client-id" {
  project   = var.secret_project
  secret_id = "client-id_${var.client_name}"

  labels = {
    terraformed = "true"
    secret-data = "terraform"
    client      = var.client_name
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "client-id-version" {
  secret      = google_secret_manager_secret.client-id.id
  secret_data = random_string.postfix.id
}


resource "google_storage_hmac_key" "key" {
  service_account_email = google_service_account.sa.email
}

resource "google_secret_manager_secret" "client-key" {
  project   = var.secret_project
  secret_id = "client-key_${var.client_name}"

  labels = {
    terraformed = "true"
    secret-data = "terraform"
    client      = var.client_name
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "client-key-version" {
  secret      = google_secret_manager_secret.client-key.id
  secret_data = local.client-key
}

locals {
  client-key = <<-EOT
    ACCESS_KEY=${google_storage_hmac_key.key.access_id}
    SECRET_ACCESS_KEY=${google_storage_hmac_key.key.secret}
    EOT
}
