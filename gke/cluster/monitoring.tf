resource "google_service_account" "monitoring" {
  account_id   = "k8s-monitoring"
  display_name = "Monitoring"
  description  = "Service account used for the the stackdriver exporter application"
  project      = var.project_id
}

resource "google_service_account_iam_member" "workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[monitoring/stackdriver-exporter-${var.region}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.monitoring.name
}

resource "google_project_iam_member" "monitor-scopes" {
  project = "moove-monitor-${var.environment}"
  role    = "roles/monitoring.metricsScopesViewer"
  member  = "serviceAccount:${google_service_account.monitoring.email}"
}

resource "google_project_iam_member" "monitor" {
  project = "moove-monitor-${var.environment}"
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.monitoring.email}"
}

resource "google_project_iam_member" "staging-monitor" {
  count   = var.environment == "production" ? 1 : 0
  project = "moove-monitor-staging"
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.monitoring.email}"
}
