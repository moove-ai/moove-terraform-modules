resource "google_secret_manager_secret" "client-id" {
  count     = var.client_id != "" ? 1 : 0
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
  count       = var.client_id != "" ? 1 : 0
  secret      = google_secret_manager_secret.client-id[0].id
  secret_data = var.client_id
}


resource "google_storage_hmac_key" "client-hmac-key" {
  count                 = var.client_hmac_key ? 1 : 0
  project               = local.service_account_project_id
  service_account_email = var.create_service_account ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email
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

resource "google_service_account_key" "client-sa-key" {
  count              = var.client_sa_key ? 1 : 0
  service_account_id = google_service_account.service-account[0].name
}

resource "google_secret_manager_secret" "client-sa-key" {
  count     = var.client_sa_key ? 1 : 0
  project   = var.secret_project
  secret_id = "client-sa-key_${var.client_name}"

  labels = {
    terraformed = "true"
    secret-data = "terraform"
    client      = var.client_name
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "client-sa-key" {
  count       = var.client_sa_key ? 1 : 0
  secret      = google_secret_manager_secret.client-sa-key[0].id
  secret_data = base64decode(google_service_account_key.client-sa-key[0].private_key)
}

resource "google_secret_manager_secret_version" "client-hmac-key" {
  count       = var.client_hmac_key ? 1 : 0
  secret      = google_secret_manager_secret.client-hmac-key[0].id
  secret_data = local.hmac_key_data
}

locals {
  hmac_key_data = <<-EOT
    ACCESS_KEY=${var.client_hmac_key ? google_storage_hmac_key.client-hmac-key[0].access_id : "null"}
    SECRET_KEY=${var.client_hmac_key ? google_storage_hmac_key.client-hmac-key[0].secret : "null"} 
    EOT
}
