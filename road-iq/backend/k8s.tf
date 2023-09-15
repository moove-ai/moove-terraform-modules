resource "google_service_account_iam_member" "workload-identity" {
  count              = var.k8s_cluster_project_id == "" ? 0 : 1
  member             = "serviceAccount:${var.k8s_cluster_project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = var.create_service_account ? google_service_account.sa[0].name : data.google_service_account.sa[0].name
}

resource "google_secret_manager_secret_iam_member" "k8s-scoring-config-secret-iam" {
  count      = var.k8s_cluster_project_id == "" ? 0 : 1
  project    = google_secret_manager_secret.scoring-api-config.project
  secret_id  = google_secret_manager_secret.scoring-api-config.secret_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${var.create_service_account ? google_service_account.sa[0].email : data.google_service_account.sa[0].email}"
  depends_on = [google_secret_manager_secret.scoring-api-config]
}

resource "google_secret_manager_secret_iam_member" "k8s-scoring-config-secret-viewer-iam" {
  count      = var.k8s_cluster_project_id == "" ? 0 : 1
  project    = google_secret_manager_secret.scoring-api-config.project
  secret_id  = google_secret_manager_secret.scoring-api-config.secret_id
  role       = "roles/secretmanager.viewer"
  member     = "serviceAccount:${var.create_service_account ? google_service_account.sa[0].email : data.google_service_account.sa[0].email}"
  depends_on = [google_secret_manager_secret.scoring-api-config]
}
