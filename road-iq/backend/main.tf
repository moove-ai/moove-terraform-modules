# Service Account
locals {
  service_account_project_id = var.service_account_project_id == "" ? var.project_id : var.service_account_project_id
  db_instance_project_id     = var.db_instance_project_id == "" ? var.project_id : var.db_instance_project_id
}
data "google_service_account" "sa" {
  count      = var.create_service_account ? 0 : 1
  project    = local.service_account_project_id
  account_id = var.service_account_id
}

resource "google_service_account" "sa" {
  count        = var.create_service_account ? 1 : 0
  project      = local.service_account_project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = var.service_account_description
}

resource "google_secret_manager_secret_iam_member" "scoring-config" {
  project    = google_secret_manager_secret.scoring-api-config.project
  secret_id  = var.scoring_api_config_secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${var.create_service_account ? google_service_account.sa[0].email : data.google_service_account.sa[0].email}"
  depends_on = [google_secret_manager_secret.scoring-api-config]
}

# SQL Instance
resource "google_sql_database_instance" "psql" {
  name             = var.db_instance_name
  project          = local.db_instance_project_id
  database_version = "POSTGRES_11"
  region           = var.region

  settings {
    tier = var.db_instance_tier
  }
}

resource "google_storage_bucket_iam_member" "weather-bucket" {
  bucket = var.weather_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.create_service_account ? google_service_account.sa[0].email : data.google_service_account.sa[0].email}"
}
