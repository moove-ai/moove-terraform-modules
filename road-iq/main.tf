locals {
  namespace          = var.namespace != "" ? var.namespace : var.environment
  cluster_project_id = var.cluster_project_id != "" ? var.cluster_project_id : var.project_id
}


resource "google_service_account" "service-account" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Road IQ (K8s)"
  description  = "Used for the road-iq application."
}


resource "google_service_account_iam_member" "workload-identity" {
  for_each           = toset(var.regions)
  member             = "serviceAccount:${local.cluster_project_id}.svc.id.goog[${local.namespace}/road-iq-backend-${var.environment}-${each.key}-deployment]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.service-account.name
}

resource "google_secret_manager_secret_iam_member" "scoring-config" {
  project   = "moove-platform-production"
  secret_id = "scoring-api-config"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service-account.email}"
}
