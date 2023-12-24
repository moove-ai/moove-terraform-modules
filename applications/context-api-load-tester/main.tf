data "google_secret_manager_secret" "secret" {
    project = var.secret_project_id
    secret_id = var.api_key_secret_id
}

resource "google_service_account" "sa" {
    project = var.project_id

    account_id = var.service_account_id
    display_name = var.service_account_display_name
    description = var.service_account_description
}

resource "google_secret_manager_secret_iam_member" "member" {
  project = data.google_secret_manager_secret.secret.project
  secret_id = data.google_secret_manager_secret.secret.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = google_service_account.sa.member
}

resource "google_project_iam_member" "workload_identity_member" {
  project = var.k8s_cluster_project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]"
}

resource "google_project_iam_member" "sa_container_developer" {
  project = var.k8s_cluster_project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.sa.email}"
}
