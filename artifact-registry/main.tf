#resource "google_artifact_registry_repository_iam_member" "member" {
#  project = google_artifact_registry_repository.my-repo.project
#  location = google_artifact_registry_repository.my-repo.location
#  repository = google_artifact_registry_repository.my-repo.name
#  role = "roles/artifactregistry.reader"
#  member = "user:jane@example.com"
#}

resource "google_artifact_registry_repository" "repository" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  description   = var.repository_description
  format        = var.format
  labels        = {
    environment = var.environment
    project_id  = var.project_id
  }
}