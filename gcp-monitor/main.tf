/**
 * # GCP Monitor
 *
 * Takes a list of projects (monitored_projects) and attaches them as monitoring scopes to a parent project.
 * Placed in the `[ENVIRONMENT]/projects` folder. 
 * Metrics scope project must be created separately. (Use a module in projects as a template)
 * 
 * Written by Alex Merenda for moove.ai
 */
locals {
  projects_map = { for id in var.monitored_projects : id => id }
}

resource "google_monitoring_monitored_project" "project" {
  provider      = google-beta
  for_each      = local.projects_map
  metrics_scope = var.metrics_scope
  name          = each.key
}

resource "google_service_account" "monitor" {
  project      = var.metrics_scope
  account_id   = "monitor"
  display_name = "Service account for monitoring ${var.environment}"
}

resource "google_project_iam_member" "scopes-iam" {
  for_each = local.projects_map
  project  = each.key
  role     = "roles/monitoring.metricsScopesViewer"
  member   = "serviceAccount:${google_service_account.monitor.email}"
}

resource "google_project_iam_member" "viewer-iam" {
  for_each = local.projects_map
  project  = each.key
  role     = "roles/monitoring.viewer"
  member   = "serviceAccount:${google_service_account.monitor.email}"
}

resource "google_project_iam_member" "monitoring-viewer-iam" {
  project = var.metrics_scope
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.monitor.email}"
}

resource "google_project_iam_member" "browser-iam" {
  project = var.metrics_scope
  role    = "roles/browser"
  member  = "serviceAccount:${google_service_account.monitor.email}"
}

resource "google_service_account_key" "monitor-key" {
  service_account_id = google_service_account.monitor.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_secret_manager_secret" "monitor-sa" {
  project   = var.secret_project_id
  secret_id = "${var.environment}_monitor-grafana-datasource"

  labels = {
    environment = var.environment
    function    = "monitoring"
    client      = "moove"
    terraformed = "true"
    secret-data = "terraform"
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "monitor-sa-key" {
  secret      = google_secret_manager_secret.monitor-sa.id
  secret_data = local.datasource
}

resource "random_string" "suffix" {
  length  = "4"
  special = false
  upper   = false
}
