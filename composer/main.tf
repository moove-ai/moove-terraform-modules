/**
 * # Composer
 *
 * Creates composer resources
 *
 * [based on composer](https://registry.terraform.io/modules/terraform-google-modules/composer/google/latest/submodules/create_environment_v2)
 * 
 * Written by Alex Merenda for moove.ai
 */

resource "google_service_account" "serviceaccount" {
  count       = var.create_service_account ? 1 : 0
  project     = var.project_id
  account_id  = var.service_account_name
  description = "Service Account used for composer"
  depends_on = [
    google_project_service.composer,
  ]
}

resource "google_project_service" "composer" {
  project                    = var.project_id
  service                    = "composer.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false

  timeouts {
    create = "5m"
    update = "5m"
  }
}

data "google_project" "project" {
  project_id = var.project_id
}

data "google_service_account" "serviceaccount" {
  count      = var.create_service_account ? 0 : 1
  project    = var.project_id
  account_id = var.service_account_name
}

resource "google_project_iam_member" "worker" {
  project = var.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${var.create_service_account == false ? data.google_service_account.serviceaccount[0].email : google_service_account.serviceaccount[0].email}"
  depends_on = [
    google_project_service.composer,
    google_service_account.serviceaccount
  ]
}

data "google_secret_manager_secret" "pagerduty-key" {
  project   = var.secret_project_id
  secret_id = var.composer_alerts_secret_id
}

resource "google_secret_manager_secret_iam_member" "member" {
  project   = data.google_secret_manager_secret.pagerduty-key.project
  secret_id = data.google_secret_manager_secret.pagerduty-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.create_service_account == false ? data.google_service_account.serviceaccount[0].email : google_service_account.serviceaccount[0].email}"
}
