provider "kubernetes" {
  config_path = "~/.kube/config"
  proxy_url = "http://${var.environment}-${var.region}.gke.moove.co.in:8888"
  config_context_cluster = "gke_${var.project_id}_${var.region}_${var.environment}-${var.region}"
}

data "google_service_account" "build_service_account" {
  project = var.project_id
  account_id = var.service_account
}

resource "google_cloudbuild_trigger" "k8s-build-trigger" {
  provider    = google-beta
  project     = var.project_id
  name        = "${var.prefix}-${var.region}-app-${var.app_name}"
  description = "Deploys the ${var.app_name} Application to the ${var.environment}-${var.region} GKE cluster"
  service_account = data.google_service_account.build_service_account.id

  tags = concat([
    "k8s",
    "deploy",
    "apps",
    var.app_name
  ], var.tags)

  included_files = [
    "releases/apps/${var.app_name}/configs/${var.environment}/**",
    "releases/apps/${var.app_name}/values/values.yaml",
    "releases/apps/${var.app_name}/values/${var.environment}.yaml",
    "releases/apps/${var.app_name}/values/${var.environment}-pilot.yaml",
    "releases/apps/${var.app_name}/helmfile.yaml",
  ]

  github {
    owner = "moove-ai"
    name  = "k8s-deployments"

    push {
      branch = "^${var.ci_cd_branch}$"
    }
  }

  build {
    logs_bucket = "gs://moove-${var.environment == "data-pipelines" ? "production" : var.environment}-build-logs"
    available_secrets {
      secret_manager {
        env          = "GITHUB_TOKEN"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
      }
    }

    step {
      id = "clone-ops-repo"
      name = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = [
        "-c",
        "git clone --depth 1 --branch main --single-branch https://$$GITHUB_TOKEN@github.com/moove-ai/k8s-git-ops.git /workspace/k8s-git-ops",
        ]
      secret_env = [
        "GITHUB_TOKEN",
        ]
    }

    step {
      id = "clear-existing-templates"
      wait_for = ["clone-ops-repo"]
      name = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [
        "-c",
        "rm -fr /workspace/k8s-git-ops/${var.gke_cluster}/apps/${var.app_name}/*",
        ]
      secret_env = [
        "GITHUB_TOKEN",
      ]
    }

    step {
      id = "render-template"
      wait_for = ["clear-existing-templates"]
      name = "${var.helmfile_image}:${var.helmfile_image_tag}"
      entrypoint = "bash"
      env = [
        "KUSTOMIZE_PLUGIN_HOME=/root/",
        "OUTPUT_DIR=${var.app_output_dir}"
      ]
      args = [
        "-c",
        "helmfile --environment ${var.environment} --file releases/apps/${var.app_name}/helmfile.yaml template --output-dir-template /workspace/k8s-git-ops/${var.gke_cluster}/apps/${var.app_name}",
      ]
      secret_env = [
        "GITHUB_TOKEN",
      ]
    }

    step {
      id = "trigger-cd"
      wait_for = ["render-template"]
      name = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = [
        "-c",
        "cd /workspace/k8s-git-ops/ && git config user.name moove-devopsbot && git config user.email ${var.service_account} && git pull && git add -A ${var.gke_cluster}/apps/ && git commit -m \"deploys ${var.app_name} to ${var.environment}\" && git push origin main"
      ]
    }
  }
}
