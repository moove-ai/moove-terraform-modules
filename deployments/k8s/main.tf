locals {
  build_args = var.build_args == "" ? var.build_args : var.build_args
  ci_cd_name_override = var.ci_cd_name_override == "" ? var.app_name : var.ci_cd_name_override
}


resource "google_cloudbuild_trigger" "build" {
  count           = var.build ? 1 : 0
  provider        = google-beta
  project         = var.project_id
  name            = "build-k8s-${var.type}-${var.app_name}"
  description     = "Builds the ${var.app_name} container and triggers an automated deployment via ArgoCD"
  service_account = "projects/${var.project_id}/serviceAccounts/privileged-builder@${var.project_id}.iam.gserviceaccount.com"

  tags = concat([
    "k8s",
    "build",
    var.app_name
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

  substitutions = {
    _CI_CD_BRANCH = var.ci_cd_branch
  }

  build {
    logs_bucket = "gs://moove-${var.environment == "data-pipelines" ? "production" : var.environment}-build-logs"
    timeout     = var.build_timeout
    images = [
      "gcr.io/${var.project_id}/${var.app_name}:$COMMIT_SHA",
      "gcr.io/${var.project_id}/${var.app_name}:latest",
    ]

    available_secrets {
      secret_manager {
        env          = "GITHUB_TOKEN"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
      }
    }

    dynamic "options" {
      for_each = var.build_instance == "" ? [] : [0]
      content {
        machine_type = var.build_instance
      }
    }

    step {
      id   = "build-container"
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        local.build_args,
        "-t", "gcr.io/${var.project_id}/${var.app_name}:$COMMIT_SHA",
        "-t", "gcr.io/${var.project_id}/${var.app_name}:latest",
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

    step {
      id         = "clone-deployment-repo"
      wait_for   = ["build-container"]
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "git clone --depth 1 --branch $_CI_CD_BRANCH --single-branch",
        "https://$$GITHUB_TOKEN@github.com/moove-ai/k8s-deployments.git /workspace/k8s-deployments",
      ])]
      secret_env = [
        "GITHUB_TOKEN",
      ]
    }

    step {
      id         = "update-permissions"
      wait_for   = ["clone-deployment-repo"]
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "chmod -R 0777",
        "/workspace/k8s-deployments"
      ])]
    }

    step {
      id       = "update-deployment"
      wait_for = ["update-permissions"]
      name     = "mikefarah/yq"
      args = [
        "e", "${var.tag_path} = \"$COMMIT_SHA\"",
        "-i", "/workspace/k8s-deployments/releases/${var.type}/${local.ci_cd_name_override}/values/${var.environment}.yaml"
      ]
    }

    step {
      id         = "trigger-cd"
      wait_for   = ["update-deployment"]
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "cd /workspace/k8s-deployments/ &&",
        "_AUTHOR=$$(git --no-pager show -s --format='%an') &&",
        "git config user.name  $$_AUTHOR &&",
        "git config user.email devopsbot@moove.ai &&",
        "git pull && git add -A &&",
        "git commit -m \"deploys ${var.app_name} to ${var.environment}-${var.region}\" &&",
        "git push origin $_CI_CD_BRANCH"
      ])]
    }
  }
}

resource "google_cloudbuild_trigger" "deployment" {
  project         = var.project_id
  name            = "${var.prefix}-${var.region}-${var.type}-${var.app_name}"
  description     = "Deploys the ${var.app_name} Application to the ${var.environment}-${var.region} GKE cluster"
  service_account = "projects/${var.project_id}/serviceAccounts/privileged-builder@${var.project_id}.iam.gserviceaccount.com"

  tags = concat([
    "k8s",
    "deploy",
    "${var.type}",
    var.app_name,
  ], var.build_tags)

  included_files = [
    "releases/${var.type}/${local.ci_cd_name_override}/configs/${var.environment}/**",
    "releases/${var.type}/${local.ci_cd_name_override}/values/values.yaml",
    "releases/${var.type}/${local.ci_cd_name_override}/values/${var.environment}.yaml",
    "releases/${var.type}/${local.ci_cd_name_override}/values/${var.environment}-pilot.yaml",
    "releases/${var.type}/${local.ci_cd_name_override}/helmfile.yaml",
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
      id         = "clone-ops-repo"
      name       = "gcr.io/cloud-builders/git"
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
      id         = "clear-existing-templates"
      wait_for   = ["clone-ops-repo"]
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [
        "-c",
        "rm -fr /workspace/k8s-git-ops/${var.gke_cluster}/${var.type}/${local.ci_cd_name_override}/*",
      ]
      secret_env = [
        "GITHUB_TOKEN",
      ]
    }

    step {
      id         = "render-template"
      wait_for   = ["clear-existing-templates"]
      name       = "${var.helmfile_image}:${var.helmfile_image_tag}"
      entrypoint = "bash"
      env = [
        "KUSTOMIZE_PLUGIN_HOME=/root/",
        "OUTPUT_DIR=${var.type}/"
      ]
      args = [
        "-c",
        "helmfile --environment ${var.environment} --file releases/${var.type}/${local.ci_cd_name_override}/helmfile.yaml template --output-dir-template /workspace/k8s-git-ops/${var.gke_cluster}/${var.type}/${var.app_name}",
      ]
      secret_env = [
        "GITHUB_TOKEN",
      ]
    }

    step {
      id         = "trigger-cd"
      wait_for   = ["render-template"]
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = [
        "-c",
        "cd /workspace/k8s-git-ops/ && git config user.name moove-devopsbot && git config user.email devopsbot@moove.ai && git pull && git add -A ${var.gke_cluster}/${var.type}/ && git commit -m \"deploys ${local.ci_cd_name_override} to ${var.environment}\" && git push origin main"
      ]
    }
  }
}
