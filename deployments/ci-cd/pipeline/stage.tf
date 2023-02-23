resource "google_cloudbuild_trigger" "release-trigger" {
  name            = var.stage_name
  project         = "moove-builds-a747"
  service_account = "projects/moove-builds-a747/serviceAccounts/deployer@moove-builds-a747.iam.gserviceaccount.com"

  github {
    owner = "moove-ai"
    name  = var.github_repo
    pull_request {
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
      id         = "clone-repo"
      name       = "maniator/gh"
      entrypoint = "sh"

      args = ["-c", join(" ", [
        "gh repo clone moove-ai/$REPO_NAME /workspace/repo -- --branch $BRANCH_NAME" , "&&",
        "cd /workspace/repo", "&&", 
        "echo $(git rev-parse --abbrev-ref HEAD |  tr -d -c 0-9.) > /workspace/version.txt"
      ])]

      secret_env = [
        "GITHUB_TOKEN"
      ]
    }

    step {
      id         = "create-pr"
      name       = "maniator/gh"
      entrypoint = "sh"

      args = ["-c", join(" ", [
        "cd /workspace/repo",
        "&&", 
        "gh pr create --title \"Release $(cat /workspace/version.txt)\" --body \"Automated commit releasing version $(cat /workspace/version.txt)\" -B $_MAIN_BRANCH > /workspace/url.txt",
      ])]

      secret_env = [
        "GITHUB_TOKEN"
      ]
    }

    step {
      id         = "print-pr"
      name       = "maniator/gh"
      entrypoint = "sh"

      args = ["-c", join(" ", [
        "cat /workspace/url.txt"
      ])]

      secret_env = [
        "GITHUB_TOKEN"
      ]
    }
  }
}
