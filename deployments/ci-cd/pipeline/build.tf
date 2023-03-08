resource "google_cloudstage_trigger" "build" {
  name     = local.stage_name
  project  = var.project_id
  service_account = "projects/moove-builds-a747/serviceAccounts/deployer@moove-builds-a747.iam.gserviceaccount.com"

  included_files = local.stage_included_files
  ignored_files = local.stage_ignored_files

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.stage_branch_pattern
    }
  }

  build {
    logs_bucket = "gs://moove-build-logs"
    timeout     = var.stage_timeout
    images = [
      "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA",
      "gcr.io/$PROJECT_ID/$REPO_NAME:cache",
    ]

    available_secrets {
      secret_manager {
        env          = "GITHUB_TOKEN"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
      }
    }

    dynamic "options" {
      for_each = var.stage_instance != "" ? [0] : []
      content {
        machine_type = var.stage_instance
      }
    }

    step {
      id   = "build-container"
      name = "gcr.io/cloud-builders/docker"
      args = local.build_args
    }

    step {
      id         = "unit-tests"
      wait_for   = ["build-container"]
      name       = "gcr.io/cloud-builders/git"
      entrypoint = local.test_entrypoint
      args = local.test_args
    }

    step {
      id         = "push-cache"
      name       = "gcr.io/cloud-builders/docker"
      wait_for   = ["unit-tests"]
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "docker",
        "push",
        "gcr.io/$PROJECT_ID/$REPO_NAME:cache",
        "&& echo 'pushed container'"
      ])]
    }
  }
}
