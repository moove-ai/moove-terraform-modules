resource "google_cloudbuild_trigger" "deploy-trigger" {
  name     = var.deploy_name
  project = "moove-builds-a747"
  service_account = "projects/moove-builds-a747/serviceAccounts/deployer@moove-builds-a747.iam.gserviceaccount.com"

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.deploy_branch
    }
  }

  substitutions = {
    _MAIN_BRANCH = "main"
  }

  build {
    logs_bucket = "gs://moove-build-logs"

    available_secrets {
      secret_manager {
        env          = "GITHUB_TOKEN"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
      }
    }

    step {
      id   = "clone-k8s-apps"
      name = "maniator/gh"
      entrypoint = "sh"
      args = ["-c", join(" ", [
        "gh repo clone moove-ai/k8s-apps", 
      ])]
      secret_env = [
        "GITHUB_TOKEN"
      ]
    }

    step {
      id   = "deploy"
      name = "mikefarah/yq"
      entrypoint = "sh"
      args = ["-c", join(" ", [
        "cd /workspace/k8s-apps", "&&",
        "yq '.argocdApplications.${REPO_NAME}.imageTag = "v$(git rev-parse --abbrev-ref HEAD |  tr -d -c 0-9.)"' apps/charts/production.yaml", "&&",
        "git add apps/charts/production.yaml", "&&",
        "git commit -m '${REPO_NAME} version $(git rev-parse --abbrev-ref HEAD |  tr -d -c 0-9.) deployed to production'"
      ])]
      secret_env = [
        "GITHUB_TOKEN"
      ]
    }
  }
}
