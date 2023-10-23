locals {
  service_account_display_name = var.service_account_display_name != "" ? var.service_account_display_name : var.service_account_id
  service_account_description  = var.service_account_description != "" ? var.service_account_description : "${var.service_account_id} service account"
}


resource "google_service_account" "serviceaccount" {
  count = var.create_serviceaccount ? 1 : 0

  project      = var.project_id
  account_id   = var.service_account_id
  display_name = local.serviceaccount_display_name
  description  = local.serviceaccount_description
}

data "google_service_account" "serviceaccount" {
  count = var.create_serviceaccount ? 0 : 1

  project    = var.project_id
  account_id = var.serviceaccount_id
}

resource "google_service_account_iam_binding" "workload-identity-binding" {

  service_account_id = var.create_serviceaccount ? google_service_account.serviceaccount[0].name : data.google_service_account.my_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.gke_project_id}.svc.id.goog[${var.environment}/${var.gke_serviceaccount_name}]"
  ]
}