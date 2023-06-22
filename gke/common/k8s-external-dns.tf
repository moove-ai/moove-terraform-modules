data "google_service_account" "dns-admin" {
  account_id = "dns-admin"
  project    = "moove-systems"
}

resource "google_service_account_iam_member" "dns-admin-workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/external-dns]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = data.google_service_account.dns-admin.name
}
