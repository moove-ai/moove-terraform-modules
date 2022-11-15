/**
 * # deployments/common
 *
 * Creates common deployment resouces. All environments need this.
 *
 * Should be installed on all environments in the `moove-platform-$ENVIRONMENT` project
 * 
 * 
 * Written by Alex Merenda for moove.ai
 */

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

resource "google_container_registry" "registry" {
  project = var.project_id
}

resource "google_storage_bucket" "build-logs" {
  name                        = "moove-${var.environment}-build-logs"
  project                     = var.project_id
  location                    = var.build_logs_bucket_location
  uniform_bucket_level_access = true

  labels = {
    "environment" = var.environment
    "function"    = "build-logs"
  }

  lifecycle_rule {
    condition {
      age = 365 # keeps 1 year of build logs
    }

    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket" "build-cache" {
  name                        = "moove-${var.environment}-build-cache"
  project                     = var.project_id
  location                    = var.build_cache_bucket_location
  uniform_bucket_level_access = true

  labels = {
    "environment" = var.environment
    "function"    = "build-cache"
  }

  lifecycle_rule {
    condition {
      age = 90
    }

    action {
      type = "Delete"
    }
  }
}
