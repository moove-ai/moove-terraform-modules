locals {
  cloudbuild_file = var.cloudbuild_file != "" ? var.cloudbuild_file : "cloudbuild.yaml"
  #ci_branch_pattern = var.ci_branch_pattern != "" ? var.ci_branch_pattern : "^release\/.+|^feature\/.+|^hotfix\/.+"
}

resource "google_cloudbuild_trigger" "build-trigger" {
  name     = var.build_name
  filename = local.cloudbuild_file
  project  = var.project_id

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.ci_branch_pattern
    }
  }
}
