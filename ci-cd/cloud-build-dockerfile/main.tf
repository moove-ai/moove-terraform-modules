resource "google_cloudbuild_trigger" "test-trigger" {
  name            = var.build_name
  location        = var.location
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"
  included_files  = var.build_included_files
  ignored_files   = var.build_ignored_files
  tags            = var.build_tags
  disabled        = var.disable_trigger

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.build_branch_pattern
    }
  }
  substitutions = {
    _IMAGE_NAME = var.image_name
    _IMAGE_TAG  = var.image_tag
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "us-docker.pkg.dev/$PROJECT_ID/docker-us/${_IMAGE_NAME}:${_IMAGE_TAG}",
        "-t", "us-docker.pkg.dev/$PROJECT_ID/docker-us/${_IMAGE_NAME}:${SHORT_SHA}",
      "."]
    }
    images = [
      "us-docker.pkg.dev/$PROJECT_ID/docker-us/${_IMAGE_NAME}:${_IMAGE_TAG}",
      "us-docker.pkg.dev/$PROJECT_ID/docker-us/${_IMAGE_NAME}:${SHORT_SHA}",
    ]
  }
}
