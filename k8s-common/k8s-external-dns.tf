data "google_service_account" "dns-admin" {
  count      = var.install_external_dns ? 1 : 0
  account_id = "dns-admin"
  project    = "moove-systems"
}

resource "google_service_account_iam_member" "dns-admin-workload-identity" {
  count              = var.install_external_dns ? 1 : 0
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/external-dns]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = data.google_service_account.dns-admin[0].name
}
