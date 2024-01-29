locals {
  test_build_name = var.test_build_name != "" ? var.test_build_name : "test-${var.github_repo}-dags"
  stage_build_name = var.stage_build_name != "" ? var.stage_build_name : "stage-${var.github_repo}-dags"
  deploy_build_name = var.deploy_build_name != "" ? var.deploy_build_name : "deplpy-${var.github_repo}-dags"
}

resource "google_cloudbuild_trigger" "test_trigger" {
  project = var.build_project_id
  name = local.test_build_name
  location = "global"

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      # No branch specified, so it triggers on push to any branch
    }
  }

  build {
    step {
      name = "python:3.8-slim"
      entrypoint = "pip"
      args = ["install", "-r", "requirements.txt"]
    }

    step {
      name = "python:3.8-slim"
      entrypoint = "pip"
      args = ["install", "-r", "requirements-test.txt", "--user"]
    }

    step {
      name = "python:3.8-slim"
      entrypoint = "python3.8"
      args = ["-m", "pytest", "-s", "dags/"]
    }
  }
}

resource "google_cloudbuild_trigger" "stage_trigger" {
  project = var.build_project_id
  name = local.stage_build_name
  location = "global"

  github {
    owner = var.github_owner
    name  = var.github_repo

    pull_request {
      branch = var.stage_build_branch_pattern
    }
  }

  build {

    step {
      name = "python"
      entrypoint = "python"
      args = ["utils/add_dags_to_composer.py", "--dags_directory=${_DAGS_DIRECTORY}", "--dags_bucket=${_DAGS_BUCKET}"]
    }
    
    step {
      name = "python"
      entrypoint = "python"
      args = ["utils/add_dags_to_composer.py", "--dags_directory=${_DAGS_DIRECTORY}", "--dags_bucket=${_DAGS_BUCKET}"]
    }
  }
}

resource "google_cloudbuild_trigger" "deploy_trigger" {
  project = var.build_project_id
  name = local.deploy_build_name
  location = "global"

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "main"
    }
  }

  build {
    step {
      name = "python:3.8-slim"
      entrypoint = "pip"
      args = ["install", "-r", "requirements.txt"]
    }

    step {
      name = "python:3.8-slim"
      entrypoint = "pip"
      args = ["install", "-r", "requirements-test.txt", "--user"]
    }

    step {
      name = "python:3.8-slim"
      entrypoint = "python3.8"
      args = ["-m", "pytest", "-s", "dags/"]
    }
  }
}
