resource "google_project" "project" {
  name = "moove-jupyter-${var.environment}-oauth"
  project_id = "moove-jupyter-${var.environment}-oauth"
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

resource "google_iap_brand" "project_brand" {
  support_email     = "jupyter-${var.environment}-oauth@moove.ai"
  application_title = "Jupyter IAP"
  project           = google_project_service.project_service.project
}

resource "google_iap_client" "project_client" {
  display_name = "Jupyter"
  brand        =  google_iap_brand.project_brand.name
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

resource "google_cloud_identity_group" "cloud_identity_group_basic" {
  display_name         = "jupyter-${var.environment}"
  initial_group_config = "WITH_INITIAL_OWNER"

  parent = ""

  group_key {
      id = "jupyter-${var.environment}-oauth@moove.ai"
  }

 depends_on = [google_project_service.cloud_ident]
}
