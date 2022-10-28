data "google_project" "project" {
  project_id = var.project_id
}

data "google_service_account" "builder" {
  project_id = var.project_id
  account_id = "priviliged-builder"
}

resource "google_service_account" "serviceaccount" {
  count = var.create_service_account ?  1 : 0
  project = var.platform_project
  account_id = var.service_account_id
  display_name = var.service_account_name
  description = var.service_account_description
}

resource "google_project_iam_member" "run-dev" {
  project = var.platform_project
  role    = "roles/run.developer"
  member  = "serviceAccount:${data.builder.email}"
}

resource "google_service_account_iam_member" "act-as" {
  service_account_id = google_service_account.serviceaccount.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.builder.email}"
}

resource "google_project_iam_member" "vpc" {
  project = var.network_project
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:service-${data.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}
