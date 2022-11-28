resource "google_secret_manager_secret" "aws-access-key" {
  project = var.project_id
  secret_id = var.aws_access_key_name
  labels = var.labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "aws-secret-access-key" {
  project = var.project_id
  secret_id = var.aws_access_secret_key_name
  labels = var.labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "gcp-access-key" {
  project = var.project_id
  secret_id = var.gcp_access_key_name
  labels = var.labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "gcp-secret-access-key" {
  project = var.project_id
  secret_id = var.gcp_access_secret_key_name
  labels = var.labels

  replication {
    automatic = true
  }
}

resource "google_storage_hmac_key" "gcp-key" {
  project = var.project_id
  service_account_email = var.gcp_service_account
}

resource "google_secret_manager_secret_version" "gcp-access-key" {
  secret = google_secret_manager_secret.gcp-access-key.id
  secret_data = google_storage_hmac_key.gcp-key.access_id
}

resource "google_secret_manager_secret_version" "gcp-secret-access-key" {
  secret = google_secret_manager_secret.gcp-secret-access-key.id
  secret_data = google_storage_hmac_key.gcp-key.secret
}
