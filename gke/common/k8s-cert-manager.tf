resource "google_service_account_iam_member" "cert-manager-workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/cert-manager]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = data.google_service_account.dns-admin.name
}
