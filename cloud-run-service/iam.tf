data "google_project" "build-project" {
  project_id = var.build_project
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "artifact_registry_reader" {
  project = "moove-build"
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "cloud-run-reader" {
  bucket = "artifacts.${data.google_project.build-project.project_id}.appspot.com"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}
