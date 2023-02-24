resource "google_cloudbuild_trigger" "release-trigger" {
  name            = var.stage_name
  project         = "moove-builds-a747"
  service_account = "projects/moove-builds-a747/serviceAccounts/deployer@moove-builds-a747.iam.gserviceaccount.com"

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.cd_branch_pattern
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
      id         = "cache"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"

      args = ["-c", join(" ", [
        "docker pull gcr.io/$PROJECT_ID/$REPO_NAME:cache || exit 0"
      ])]
    }

    step {
      id         = "get-release-version"
      name       = "maniator/gh"
      entrypoint = "sh"

      args = ["-c", join(" ", [
        "gh repo clone moove-ai/$REPO_NAME /workspace/repo -- --branch $BRANCH_NAME" , "&&",
        "cd /workspace/repo", "&&", 
        "echo $(git rev-parse --abbrev-ref HEAD |  tr -d -c 0-9.) > /workspace/version.txt", "&&",
        "cat /workspace/version.txt"
      ])]

      secret_env = [
        "GITHUB_TOKEN"
      ]
    }

    step {
      id         = "build"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "docker", "build", 
        "-t", "gcr.io/$PROJECT_ID/$REPO_NAME:v$(cat /workspace/version.txt)",
        "-t", "gcr.io/$PROJECT_ID/$REPO_NAME:cache",
        "--cache-from", "gcr.io/$PROJECT_ID/$REPO_NAME:cache",
        "."
      ])]
    }

    step {
      id         = "push"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "docker", "image", "push", "--all-tags",
        "gcr.io/$PROJECT_ID/$REPO_NAME"
      ])]
    }

    step {
      id         = "clone-apps-repo"
      name       = "maniator/gh"
      entrypoint = "sh"

      args = ["-c", join(" ", [
        "gh repo clone moove-ai/k8s-apps /workspace/k8s-apps"
      ])]

      secret_env = [
        "GITHUB_TOKEN"
      ]
    }

    step {
      id         = "set-permissions"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "chmod 0777 /workspace/k8s-apps/apps/charts/staging.yaml"
      ])]
    }

    step {
      id         = "configure-staging"
      name       = "mikefarah/yq"
      entrypoint = "/bin/sh"
      args = ["-c", join(" ", [
        "cd /workspace/k8s-apps", "&&",
        "export VERSION=v$(cat /workspace/version.txt)", "&&",
        "cd /workspace/k8s-apps", "&&",
        "yq -i '.argocdApplications.$REPO_NAME.disable = false' apps/charts/staging.yaml", "&&",
        "yq -i '.argocdApplications.$REPO_NAME.imageTag = strenv(VERSION)' apps/charts/staging.yaml"
      ])]
    }

    step {
      id         = "staging-deploy"
      name       = "maniator/gh"
      entrypoint = "sh"
      args = ["-c", join(" ", [
        "cd /workspace/k8s-apps", "&&",
        "git config user.name 'devopsbot'", "&&",
        "git config user.email 'devopsbot@moove.ai'", "&&",
        "git remote set-url origin https://devopsbot:$$GITHUB_TOKEN@github.com/moove-ai/k8s-apps.git", "&&",
        "git add apps/charts/staging.yaml", "&&",
        "git commit -m \"staging $REPO_NAME. version: $(cat /workspace/version.txt)\"", "&&",
        "git push"
      ])]

      secret_env = [
        "GITHUB_TOKEN"
      ]
    }
  }
}
