resource "google_cloudbuild_trigger" "build" {
  provider        = google-beta
  project         = var.project_id
  name            = ""
  description     = ""
  service_account = "projects/${var.project_id}/serviceAccounts/builder@${var.project_id}.iam.gserviceaccount.com"
  #service_account = "projects/${var.project_id}/serviceAccounts/privileged-builder@${var.project_id}.iam.gserviceaccount.com"

  tags = concat([
    "build",
    "testing",
    var.app_name,
  ], var.build_tags)

  included_files = var.build_files
  ignored_files  = var.build_ignored_files

  github {
    owner = "moove-ai"
    name  = var.build_repo

    push {
      branch = "^${var.build_branch}$"
    }
  }

  build {
    logs_bucket = "gs://moove-${var.environment}-build-logs"
    timeout     = var.build_timeout
    images = [
      "gcr.io/${var.project_id}/${var.app_name}:$COMMIT_SHA",
      "gcr.io/${var.project_id}/${var.app_name}:latest",
    ]

    dynamic "options" {
      for_each = var.build_instance == "" ? [] : [0]
      content {
        machine_type = var.build_instance
      }
    }

    step {
      id   = "build-container"
      name = "gcr.io/cloud-builders/docker"
      args = ["build",
                "-t", 
                "gcr.io/${var.project_id}/${var.app_name}:$COMMIT_SHA", 
                "-t", 
                "gcr.io/${var.project_id}/${var.app_name}:latest", 
                "."
            ]
    }

    step {
      id         = "push-container"
      name       = "gcr.io/cloud-builders/docker"
      wait_for   = ["build-container"]
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "docker",
        "push",
        "gcr.io/${var.project_id}/${var.app_name}:$COMMIT_SHA",
        "&& echo 'pushed container'"
      ])]
    }
  }
}

resource "google_cloudbuild_trigger" "test" {
  provider        = google-beta
  project         = var.project_id
  name            = ""
  description     = ""
  service_account = "projects/${var.project_id}/serviceAccounts/builder@${var.project_id}.iam.gserviceaccount.com"

  tags = concat([
    "ci",
    "testing",
  ], var.build_tags)

  included_files = var.deploy_files
  ignored_files  = var.deploy_ignored_files

  github {
    owner = "moove-ai"
    name  = var.test_repo

    push {
      branch = "^${var.build_branch}$"
    }
  }

  build {
    logs_bucket = "gs://moove-${var.environment}-build-logs"
    timeout     = var.build_timeout
    images = [
      "gcr.io/${var.project_id}/${var.app_name}:$COMMIT_SHA",
      "gcr.io/${var.project_id}/${var.app_name}:latest",
    ]

    dynamic "options" {
      for_each = var.build_instance == "" ? [] : [0]
      content {
        machine_type = var.build_instance
      }
    }

    step {
      id   = "build-container"
      name = "gcr.io/cloud-builders/docker"
      args = ["build",
                "-t", 
                "gcr.io/${var.project_id}/${var.app_name}:$COMMIT_SHA", 
                "-t", 
                "gcr.io/${var.project_id}/${var.app_name}:latest", 
                "."
            ]
    }

    step {
      id         = "push-container"
      name       = "gcr.io/cloud-builders/docker"
      wait_for   = ["build-container"]
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "docker",
        "push",
        "gcr.io/${var.project_id}/${var.app_name}:$COMMIT_SHA",
        "&& echo 'pushed container'"
      ])]
    }
  }
}
