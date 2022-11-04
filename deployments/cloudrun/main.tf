resource "google_cloudbuild_trigger" "cloudrun" {
  provider        = google-beta
  project         = var.project_id
  name            = "deploy-cr-${var.service_name}"
  description     = "Deploys the ${var.service_name} Cloud Run Service."
  service_account = var.build_service_account
  tags = concat([
    "cr",
    "cloudrun",
    "deploy",
    var.service_name,
  ], var.extra_tags)
  included_files = var.build_trigger_files
  ignored_files  = var.build_ignore_files

  github {
    owner = "moove-ai"
    name  = var.repo_name

    push {
      branch = "^${var.ci_cd_branch}$"
    }
  }

  build {
    logs_bucket = "gs://moove-${var.environment == "data-pipelines" ? "production" : var.environment}-build-logs"
    #available_secrets {
    #  secret_manager {
    #    env          = "GRAFANA_API_KEY"
    #    version_name = "projects/moove-secrets/secrets/ci-cd_grafana-token/versions/latest"
    #  }
    #  secret_manager {
    #    env          = "SLACK_HOOK"
    #    version_name = "projects/moove-secrets/secrets/ci-cd_slack-webhook-token-cf-build-notification/versions/latest"
    #  }
    #}

    step {
      id   = "build-cloudrun-container"
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build", "-t", "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA", "."
      ]
    }

    step {
      id   = "push-cloudrun-container"
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push", "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA"
      ]
    }

    step {
      id         = "deploy-cloudrun-service"
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "bash"
      args = [
        "-c",
        "${local.cloudrun_deploy}"
      ]
    }

    #step {
    #  id         = "deploy-cloudrun-schedule"
    #  name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
    #  entrypoint = "bash"
    #  args = [
    #    "-c",
    #    "${var.service_trigger_topic == "" ? local.deploy_http_template : local.deploy_pubsub_template}"
    #  ]
    #}

    #step {
    #  id         = "add-grafana-annotation"
    #  wait_for   = ["deploy-cloudrun-service"]
    #  name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
    #  entrypoint = "bash"
    #  args = [
    #    "-c",
    #    local.grafana_annotation
    #  ]
    #  secret_env = [
    #    "GRAFANA_API_KEY",
    #  ]
    #}

    #step {
    #  id         = "send-slack"
    #  wait_for   = ["deploy-cloudrun-service"]
    #  name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
    #  entrypoint = "bash"
    #  args = [
    #    "-c",
    #    local.slack_message
    #  ]
    #  secret_env = [
    #    "SLACK_HOOK",
    #  ]
    #}
  }
}

