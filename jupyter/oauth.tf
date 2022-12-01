resource "random_string" "suffix" {
  length  = "4"
  special = false
  upper   = false
}

resource "google_project" "project" {
  name = "moove-jupyter-${var.environment}-oauth"
  project_id = "moove-jupyter-${var.environment}-oauth-${random_string.suffix.result}"
  folder_id = var.folder_id
  billing_account = var.billing_account
  auto_create_network = false
}

resource "google_project_service" "project_service" {
  project = google_project.project.project_id
  service = "iap.googleapis.com"
}

resource "google_project_service" "cloud-ident" {
  project = google_project.project.project_id
  service = "cloudidentity.googleapis.com"
}

resource "google_secret_manager_secret" "hub-config" {
  project = var.project_id
  secret_id = "jupyter-hub_config"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "hub-config" {
  secret = google_secret_manager_secret.hub-config.id
  secret_data = local.hub_config
}
