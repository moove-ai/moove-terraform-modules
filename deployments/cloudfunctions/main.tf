/**
 * # deployments/cloudfunction
 *
 * Creates build automation to deploy cloudfunctions 
 *
 * If you provide `function_trigger_topic` it will create a trigger to deploy the CF with a pub/sub topic (must be created seperately)
 * If `function_trigger_topic` is ommited, it will create an HTTP trigger.
 * 
 * Written by Alex Merenda for moove.ai
 */

resource "google_cloudbuild_trigger" "cloudfunction" {
  provider        = google-beta
  project         = var.project_id
  name            = "deploy-cf-${var.function_name}"
  description     = "Deploys the ${var.function_name} cloud function. ${var.summary}"
  service_account = var.service_account
  tags = concat([
    "cf",
    "cloudfunction",
    "deploy",
    var.function_name,
    var.function_runtime
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
    available_secrets {
      secret_manager {
        env          = "GRAFANA_API_KEY"
        version_name = "projects/moove-secrets/secrets/ci-cd_grafana-token/versions/latest"
      }
      secret_manager {
        env          = "SLACK_HOOK"
        version_name = "projects/moove-secrets/secrets/ci-cd_slack-webhook-token-cf-build-notification/versions/latest"
      }
    }

    step {
      id         = "deploy-cloudfunction"
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "bash"
      args = [
        "-c",
        "${var.function_trigger_topic == "" ? local.deploy_http_template : local.deploy_pubsub_template}"
      ]
    }

    step {
      id         = "add-grafana-annotation"
      wait_for   = ["deploy-cloudfunction"]
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "bash"
      args = [
        "-c",
        local.grafana_annotation
      ]
      secret_env = [
        "GRAFANA_API_KEY",
      ]
    }

    step {
      id         = "send-slack"
      wait_for   = ["deploy-cloudfunction"]
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "bash"
      args = [
        "-c",
        local.slack_message
      ]
      secret_env = [
        "SLACK_HOOK",
      ]
    }
  }
}
