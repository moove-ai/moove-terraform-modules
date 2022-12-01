resource "google_service_account" "k8s-keda" {
  count        = var.install_keda ? 1 : 0
  project      = var.project_id
  account_id   = "k8s-keda"
  display_name = "Keda Autoscaler (Kubernetes)"
  description  = "Service account used by Keda. 'keda-operator'"
}

resource "google_service_account_iam_member" "k8s-keda-workload-identity" {
  count              = var.install_keda ? 1 : 0
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/keda-operator]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-keda[0].name
}

resource "google_project_iam_member" "k8s-keda-monitoring-iam" {
  for_each = toset(var.keda_monitor_projects)
  project = each.key
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.k8s-keda[0].email}"
}
