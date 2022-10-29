resource "google_service_account" "sa" {
  project = var.project_id
  account_id = var.service_account_id
  description = var.service_account_description
  display_name = var.service_account_name
}

resource "google_service_account_iam_member" "sa-workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.k8s_sa_name}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.sa.name
}

resource "google_organization_iam_member" "sa-iam" {
  org_id = var.org_id
  role   = "roles/bigquery.metadataViewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}
