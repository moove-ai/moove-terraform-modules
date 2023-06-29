locals {
  build_name           = var.build_name != "" ? var.build_name : "build-${var.github_repo}"
  build_included_files = var.build_included_files != [] ? var.build_included_files : ["**"]
  build_ignored_files  = var.build_ignored_files != [] ? var.build_ignored_files : ["helm/**", "deploy.yaml", "stage.yaml"]
  build_tags           = [var.github_repo, "build"]
}

resource "google_cloudbuild_trigger" "build" {
  name            = local.build_name
  location        = var.location
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"
  included_files  = local.build_included_files
  ignored_files   = local.build_ignored_files
  tags            = local.build_tags

  filename = var.build_file

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.build_branch_pattern
    }
  }
}

data "google_service_account" "deployer" {
  project    = var.deployer_project_id
  account_id = var.deployer_account_id
}

resource "google_project_iam_member" "deployer-storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${data.google_service_account.deployer.email}"
}
 