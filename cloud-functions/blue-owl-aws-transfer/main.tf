locals {
  service_account_project_id   = var.service_account_project_id != "" ? var.service_account_project_id : var.project_id
  service_account_display_name = var.service_account_display_name != "" ? var.service_account_display_name : var.service_account_id
  service_account_description  = var.service_account_description != "" ? var.service_account_description : var.service_account_display_name
}

resource "google_secret_manager_secret" "gcs-access-key" {
  project   = var.project_id
  secret_id = "blue-owl-transfer-gcs-access-key"

  labels = {
    environment = var.environment
    function    = "blue-owl-aws-transfer"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "gcs-secret-key" {
  project   = var.project_id
  secret_id = "blue-owl-transfer-gcs-secret-key"

  labels = {
    environment = var.environment
    function    = "blue-owl-aws-transfer"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "aws-access-key" {
  project   = var.project_id
  secret_id = "blue-owl-transfer-aws-access-key"

  labels = {
    environment = var.environment
    function    = "blue-owl-aws-transfer"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "aws-secret-key" {
  project   = var.project_id
  secret_id = "blue-owl-transfer-aws-secret-key"

  labels = {
    environment = var.environment
    function    = "blue-owl-aws-transfer"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "gcs-access-key" {
  secret      = google_secret_manager_secret.gcs-access-key.id
  secret_data = google_storage_hmac_key.gcp_acces_key.access_id
}

resource "google_secret_manager_secret_version" "gcs-secret-key" {
  secret      = google_secret_manager_secret.gcs-secret-key.id
  secret_data = google_storage_hmac_key.gcp_acces_key.secret
}

resource "google_service_account" "runner" {
  count        = var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = var.service_account_description
}

data "google_service_account" "runner" {
  count      = var.create_service_account ? 0 : 1
  project    = local.service_account_project_id
  account_id = var.service_account_id
}

resource "google_storage_hmac_key" "gcp_acces_key" {
  project               = var.service_account_project_id
  service_account_email = var.create_service_account ? google_service_account.runner[0].email : data.google_service_account.runner[0].email
}
