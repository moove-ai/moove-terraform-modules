resource "google_project_iam_member" "security-admin" {
  project = var.cluster_network_project_id
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}