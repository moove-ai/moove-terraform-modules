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

    #dynamic "options" {
    #  for_each = var.build_instance == "" ? [] : [0]
    #  content {
    #    machine_type = var.build_instance
    #  }
    #}

    step {
      id         = "get-info"
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"

      args = ["-c", join(" ", [
        "echo $(git rev-parse --abbrev-ref HEAD |  tr -d -c 0-9.) > /version/version.txt",
      ])]

      volumes {
          name = "version"
          path = "/version"
        }
    }

    step {
      id         = "create-pr"
      name       = "maniator/gh"
      entrypoint = "sh"

      args = ["-c", join(" ", [
        "git push", 
        "&&", 
        "gh pr create --title \"Release $(cat /version/version.txt)\" --body \"Automated commit releasing version $(cat /version/version.txt)\" -B $_MAIN_BRANCH",
      ])]

      secret_env = [
        "GITHUB_TOKEN"
      ]

      volumes {
          name = "version"
          path = "/version"
        }

    }
  }
}

#resource "google_cloudbuild_trigger" "deploy-trigger" {
#  name     = var.deploy_name
#  project = "moove-builds-a747"
#  service_account = "projects/moove-builds-a747/serviceAccounts/deployer@moove-builds-a747.iam.gserviceaccount.com"
#
#  github {
#    owner = "moove-ai"
#    name  = var.github_repo
#    push {
#      branch = var.cd_branch_pattern
#    }
#  }
#
#  substitutions = {
#    _MAIN_BRANCH = "main"
#  }
#
#  build {
#    logs_bucket = "gs://moove-build-logs"
#
#    available_secrets {
#      secret_manager {
#        env          = "GITHUB_TOKEN"
#        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
#      }
#    }
#
#    #dynamic "options" {
#    #  for_each = var.build_instance == "" ? [] : [0]
#    #  content {
#    #    machine_type = var.build_instance
#    #  }
#    #}
#
#    step {
#      id   = "staging-deploy"
#      name       = "gcr.io/cloud-builders/git"
#      entrypoint = "bash"
#      args = ["-c", join(" ", [
#        "echo $(git rev-parse --abbrev-ref HEAD |  tr -d -c 0-9.) > /workspace/version.txt",
#      ])]
#    }
#
#    step {
#      id   = "create-pr"
#      name = "maniator/gh"
#      entrypoint = "sh"
#      args = ["-c", join(" ", [
#        "gh pr create --title \"Release $(cat /workspace/version.txt)\" --body \"Automated commit releasing version $(cat /workspace/version.txt)\" -B $_MAIN_BRANCH", 
#      ])]
#      secret_env = [
#        "GITHUB_TOKEN"
#      ]
#    }
#  }
#}
#