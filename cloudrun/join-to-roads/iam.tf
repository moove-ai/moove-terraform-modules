resource "google_project_iam_member" "service-network-vpc" {
  project = var.network_project
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "sa-network-vpc" {
  project = var.network_project
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "service-viewer-vpc" {
  project = var.network_project
  role    = "roles/compute.viewer"
  member  = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "sa-viewer-vpc" {
  project = var.network_project
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.sa.email}"
}
