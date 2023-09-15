resource "google_artifact_registry_repository" "docker" {
  for_each      = toset(var.regions)
  project       = module.builds.project_id
  location      = each.key
  repository_id = "docker-${each.key}"
  description   = "Docker repository for ${each.key}"
  format        = "DOCKER"
}

resource "google_project_iam_member" "deployer-artifact-reader" {
  project = module.builds.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer-admin" {
  project = module.builds.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer-artifact-writer" {
  project = module.builds.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_storage_bucket_iam_member" "deployer-us-central1-admin" {
  bucket = "us-central1.deploy-artifacts.moove-build.appspot.com"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.deployer.email}"
}
