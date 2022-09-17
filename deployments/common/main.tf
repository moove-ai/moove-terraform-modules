resource "google_service_account" "builder" {
  account_id   = "builder"
  display_name = "Cloud Build Builder"
  description  = "Service account used to run Cloud Build"
  project      = var.project_id
}

resource "google_service_account" "privileged-builder" {
  account_id   = "privileged-builder"
  display_name = "Privileged Cloud Build Builder"
  description  = "Service account used to run Cloud Build with access to secrets"
  project      = var.project_id
}

resource "google_storage_bucket" "build-logs" {
  name = "moove-${var.environment}-build-logs"
  project = var.project_id
  location = "US"
  uniform_bucket_level_access = true

  labels = {
    "environment" = var.environment
    "function" = "build-logs"
  }

  lifecycle_rule {
    condition {
      age = 730
    }

    action {
      type = "Delete"
    }
  }
}
