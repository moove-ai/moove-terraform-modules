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

resource "google_project_service" "systems-cloud-ident" {
  project = "moove-systems"
  service = "cloudidentity.googleapis.com"
}

resource "google_iap_brand" "project_brand" {
  support_email     = "jupyter-${var.environment}@moove.ai"
  application_title = "Jupyter IAP"
  project           = google_project_service.project_service.project
  depends_on = [
    module.group,
    ]
}

resource "google_iap_client" "project_client" {
  display_name = "Jupyter"
  brand        =  google_iap_brand.project_brand.name
  depends_on = [
    ]
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


module "group" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.1"

  id           = "jupyter-${var.environment}@moove.ai"
  display_name = "Jupyter ${var.environment} OAUTH"
  description  = "OAUTH for Jupyter"
  domain       = "moove.ai"
  owners       = ["terraform@moove-systems.iam.gserviceaccount.com"]
  managers     = ["alex@moove.ai"]
  members      = ["justin@moove.ai"]
}
