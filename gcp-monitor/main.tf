resource "google_monitoring_monitored_project" "project" {
  provider      = google-beta
  for_each      = toset(var.monitored_projects)
  metrics_scope = var.metrics_scope
  name          = each.key
}

resource "google_service_account" "monitor" {
  project      = var.metrics_scope
  account_id   = "monitor"
  display_name = "Service account for monitoring ${var.environment}"
}

resource "google_project_iam_member" "scopes-iam" {
  for_each = toset(var.monitored_projects)
  project  = each.key
  role     = "roles/monitoring.metricsScopesViewer"
  member   = "serviceAccount:${google_service_account.monitor.email}"
}

resource "google_project_iam_member" "viewer-iam" {
  for_each = toset(var.monitored_projects)
  project  = each.key
  role     = "roles/monitoring.viewer"
  member   = "serviceAccount:${google_service_account.monitor.email}"
}
