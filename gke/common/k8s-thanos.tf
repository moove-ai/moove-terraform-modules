locals {
  service_account_project_id = var.service_account_project_id != "" ? var.service_account_project_id : var.project_id
}

data "google_service_account" "k8s-thanos" {
  count      = var.create_service_account ? 0 : 1
  account_id = var.service_account_name
  project    = local.service_account_project_id
}

resource "google_service_account" "k8s-thanos" {
  count      = var.create_service_account ? 1 : 0
  account_id = var.service_account_name
  project    = local.service_account_project_id
}
