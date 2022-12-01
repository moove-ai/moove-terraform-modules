resource "google_service_account_iam_member" "dns-admin-data-pipelines-workload-identity" {
  count              = var.install_cert_manager ? 1 : 0
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/cert-manager]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = data.google_service_account.dns-admin[0].name
}
