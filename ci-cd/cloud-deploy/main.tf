locals {
  build_name           = var.build_name != "" ? var.build_name : "build-${var.github_repo}"
  build_included_files = var.build_included_files != [] ? var.build_included_files : ["**"]
  build_ignored_files  = var.build_ignored_files != [] ? var.build_ignored_files : ["helm/**", "deploy.yaml", "stage.yaml"]
  build_tags           = [var.github_repo]
  substitutions = merge({
    _RELEASE_NAME = var.deploy_name
  }, var.build_additional_substitutions)
}

resource "google_cloudbuild_trigger" "build" {
  count           = var.auto_build ? 1 : 0
  name            = local.build_name
  location        = var.location
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"
  included_files  = local.build_included_files
  ignored_files   = local.build_ignored_files
  tags            = concat(local.build_tags, var.build_tags)
  disabled        = var.disable_trigger

  filename = var.build_file

  substitutions = local.substitutions

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.build_branch_pattern
    }
  }
}

resource "google_cloudbuild_trigger" "manual-build" {
  count           = var.auto_build ? 0 : 1
  name            = local.build_name
  location        = var.location
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"
  included_files  = local.build_included_files
  ignored_files   = local.build_ignored_files
  tags            = concat(local.build_tags, var.build_tags)
  disabled        = var.disable_trigger

  substitutions = var.substitutions

  git_file_source {
    path      = "cloudbuild.yaml"
    repo_type = "GITHUB"
    revision  = "refs/heads/main"
    uri       = "https://github.com/moove-ai/${var.github_repo}"
  }

  source_to_build {
    ref       = "refs/heads/${var.build_branch_pattern}"
    repo_type = "GITHUB"
    uri       = "https://github.com/moove-ai/${var.github_repo}"
  }
}

resource "google_clouddeploy_target" "target" {
  for_each = var.pipeline_targets

  project     = each.value[0].project_id
  location    = var.deploy_region
  name        = each.value[0].name
  description = each.value[0].description

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account   = each.value[0].service_account
  }

  require_approval = false

  run {
    location = "projects/${each.value[0].deploy_project}/locations/${each.value[0].deploy_region}"
  }
  provider = google-beta
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
 