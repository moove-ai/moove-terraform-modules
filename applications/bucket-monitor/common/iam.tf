resource "google_service_account" "sa" {
  account_id   = "k8s-bucket-monitor"
  project      = "moove-systems"
  description  = "Service account used to authenticate with the bucket monitor"
  display_name = "Bucket Monitor (k8s)"
}

resource "google_service_account_iam_member" "workload-identity" {
  for_each           = toset(var.regions)
  member             = "serviceAccount:${var.k8s_cluster_project}.svc.id.goog[${var.k8s_namespace}/bucket-monitor-mgmt-${each.key}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.sa.name
}
