resource "google_service_account" "k8s-monitor" {
  project      = var.project_id
  account_id   = "k8s-monitor"
  display_name = "Kubernetes Monitor"
  description  = "Service account used by monitoring"
}

resource "google_project_iam_member" "k8s-monitor-iam" {
  project = "moove-monitor-${var.environment}"
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.k8s-monitor.email}"
}

resource "google_service_account_iam_member" "k8s-monitor-workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[monitoring/stackdriver-exporter]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-monitor.name
}
