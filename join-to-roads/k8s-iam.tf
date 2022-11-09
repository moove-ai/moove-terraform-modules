resource "google_service_account" "k8s-join-to-roads" {
  project      = var.project_id
  account_id = var.join-to-roads-service-account
  display_name = "Join to Roads (kubernetes)"
  description = "Service account used to run the Join To Roads application"
}


resource "google_service_account_iam_member" "k8s-wejo-jtr-java-data-pipelines-workload-identity" {
  member             = "serviceAccount:${var.gke_cluster_project_id}.svc.id.goog[${var.namespace}/${var.join-to-roads-k8s-service-account}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-join-to-roads.name
}