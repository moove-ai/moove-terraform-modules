/**
 * # terraform-docs
 *
 * Creates automation to automatically document terraform
 * It creates this line
 * And this one too 
 *
 * Written by Alex Merenda for moove.ai
 */

resource "google_cloudbuild_trigger" "build" {
  provider        = google-beta
  project         = var.project_id
  name            = "automation-terraform-documentation"
  description     = "Updates terraform documentation on merge"
  service_account = "projects/${var.project_id}/serviceAccounts/builder@${var.project_id}.iam.gserviceaccount.com"

  tags = concat([
    "terraform-docs"
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

  build {
    logs_bucket = "gs://moove-${var.environment == "data-pipelines" ? "production" : var.environment}-build-logs"
    timeout     = var.build_timeout

    available_secrets {
      secret_manager {
        env          = "GITHUB_TOKEN"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
      }
    }

    step {
      id         = "clone-self"
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "git clone --depth 1 --branch ${var.build_branch} --single-branch",
        "https://$$GITHUB_TOKEN@github.com/moove-ai/${var.build_repo}.git /workspace/${var.build_repo}",
      ])]
      secret_env = [
        "GITHUB_TOKEN",
      ]
    }

    step {
      id         = "update-permissions"
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "chmod -R 0777",
        "/workspace/${var.build_repo}"
      ])]
    }

    step {
      id       = "document-terraform"
      name     = "quay.io/terraform-docs/terraform-docs:0.16.0"
      args = [
        "/workspace/${var.build_repo}"
      ]
    }

    # terraform-docs generates too many README.md files which we do not need.
    # remove these and replace the main repo readme back
    step {
      id         = "cleanup"
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "rm -f /workspace/${var.build_repo}/deployments/README.md", "&&",
        "rm -f /workspace/${var.build_repo}/README.md", "&&",
        "cp .README.md README.md"
      ])]
      secret_env = [
        "GITHUB_TOKEN",
      ]
    }


    step {
      id         = "merge-back"
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = ["-c", join(" ", [
        "cd /workspace/${var.build_repo}/ &&",
        "_AUTHOR=$$(git --no-pager show -s --format='%an') &&",
        "git config user.name  $$_AUTHOR &&",
        "git config user.email devopsbot@moove.ai &&",
        "git pull && git add -A &&",
        "git commit -m \"Automated: adds terraform documentation\" &&",
        "git push origin ${var.build_branch}"
      ])]
    }
  }
}