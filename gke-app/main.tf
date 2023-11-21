locals {
  service_account_display_name = var.service_account_display_name != "" ? var.service_account_display_name : var.service_account_id
  service_account_description  = var.service_account_description != "" ? var.service_account_description : "${var.service_account_id} service account"
}


resource "google_service_account" "service_account" {
  count = var.create_service_account ? 1 : 0

  project      = var.project_id
  account_id   = var.service_account_id
  display_name = local.service_account_display_name
  description  = local.service_account_description
}

data "google_service_account" "service_account" {
  count = var.create_service_account ? 0 : 1

  project    = var.project_id
  account_id = var.service_account_id
}

resource "google_service_account_iam_binding" "workload-identity-binding" {

  service_account_id = var.create_service_account ? google_service_account.service_account[0].name : data.google_service_account.service_account[0].name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.gke_project_id}.svc.id.goog[${var.environment}/${var.gke_service_account_name}]"
  ]
}