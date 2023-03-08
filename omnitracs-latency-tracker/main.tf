data "google_storage_bucket" "bucket" {
  name = var.bucket
}

resource "google_service_account" "service-account" {
  project      = var.project_id
  account_id   = var.service_account
  display_name = "Omnitracs Latency Tracker (K8s)"
  description  = "Used for the Omnitracs Latency Tracker. Coresponding K8s sa: ${var.k8s_sa} in namespace: ${var.namespace}"
}

resource "google_project_iam_member" "moove-systems-bq-job-user" {
  project = var.monitoring_project
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_storage_bucket_iam_member" "bucket-member" {
  bucket = data.google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_service_account_iam_member" "workload-identity" {
  for_each           = toset(var.regions)
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/omnitracs-latency-tracker-mgmt-${each.key}-deployment]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.service-account.name
}
