resource "google_cloudbuild_trigger" "build-container" {
  provider    = google-beta
  project     = var.project_id
  name        = var.build_name
  description = var.build_description
  service_account = var.service_account
  tags = concat(var.tags, [
    "build",
  ])
  included_files = [
    "Dockerfile",
    "main.py",
    "requirements.txt",
  ]

  github {
    owner = "moove-ai"
    name  = var.git_repo

    push {
      branch = "^${var.build_branch}$"
    }
  }

  build {
    logs_bucket = "gs://moove-${var.environment}-build-logs"
    timeout = var.build_timeout
    images = [
      "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA",
      "gcr.io/$PROJECT_ID/$REPO_NAME:latest",
    ]
    options {
      machine_type = var.build_instance
    }

    step {
      id       = "build-container"
      name     = "gcr.io/cloud-builders/docker"
      args     = [
        "build",
        "-t", "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA",
        "-t", "gcr.io/$PROJECT_ID/$REPO_NAME:latest",
        "."
      ]
    }
  }
}
