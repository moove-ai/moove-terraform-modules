resource "google_cloudbuild_trigger" "deployment" {
  project         = var.project_id
  name            = "bootstrap-argocd"
  description     = "Installs ArgoCD onto the specified cluster"
  service_account = "projects/${var.project_id}/serviceAccounts/privileged-builder@${var.project_id}.iam.gserviceaccount.com"

  included_files = []

  github {
    owner = "moove-ai"
    name  = "k8s-apps"

    push {
      branch = "^${var.ci_cd_branch}$"
    }
  }

  build {
    logs_bucket = "gs://moove-${var.environment}-build-logs"
    available_secrets {
      secret_manager {
        env          = "SSH_PRIVATE_KEY"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
      }
    }

    #options {
    #  worker_pool = "projects/${var.project_id}/locations/${var.region}/workerPools/${var.region}-common-worker-pool"
    #}

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
        "rm -fr /workspace/k8s-git-ops/${local.gke_cluster}/${var.type}/${local.ci_cd_name_override}/*",
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
        "helmfile --environment ${var.environment} --file releases/${var.type}/${local.ci_cd_name_override}/helmfile.yaml template --output-dir-template /workspace/k8s-git-ops/${local.gke_cluster}/${var.type}/${local.ci_cd_name_override}",
      ]
      secret_env = [
        "GITHUB_TOKEN",
      ]
    }

    step {
      id         = "deploy-template"
      wait_for   = ["render-template"]
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = [
        "-c",
        "cd /workspace/k8s-git-ops/ && git config user.name moove-devopsbot && git config user.email devopsbot@moove.ai && git pull && git add -A ${local.gke_cluster}/${var.type}/ && git commit -m \"deploys ${local.ci_cd_name_override} to ${var.environment}\" && git push origin main"
      ]
    }

    step {
      id         = "init-argo"
      wait_for   = ["deploy-template"]
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = [
        "-c",
        "touch /workspace/config && chmod 0777 /workspace/config"
      ]
    }

    step {
      id         = "trigger-argo"
      wait_for   = ["init-argo"]
      name       = "argoproj/argocd"
      entrypoint = "bash"
      args = [
        "-c",
        "echo 'logging into argocd' && argocd --config=/workspace/config --plaintext login ${var.environment}.deployments.moove.co.in:80 --username=$$ARGOCD_USER --password=$$ARGOCD_PASSWORD && echo 'triggering app sync' && argocd --config=/workspace/config app sync ${local.ci_cd_name_override}"
      ]
      secret_env = [
        "ARGOCD_USER",
        "ARGOCD_PASSWORD",
      ]
    }
  }
}