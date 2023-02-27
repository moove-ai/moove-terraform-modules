locals {
  build_file  = var.build_file != "" ? var.build_file : "build.yaml"
  stage_file  = var.stage_file != "" ? var.stage_file : "stage.yaml"
  deploy_file = var.deploy_file != "" ? var.deploy_file : "stage.yaml"

  build_name  = var.build_name != "" ? var.build_name : "build-k8s-app-${var.github_repo}"
  stage_name  = var.stage_name != "" ? var.stage_name : "stage-k8s-app-${var.github_repo}"
  deploy_name = var.deploy_name != "" ? var.deploy_name : "deploy-k8s-app-${var.github_repo}"

  build_included_files = var.build_included_files != "" ? var.build_included_files : ["**"]
  stage_included_files = var.stage_included_files != "" ? var.stage_included_files : ["**"]
  deploy_included_files = var.deploy_included_files != "" ? var.deploy_included_files : ["**"]

  build_ignored_files = var.build_ignored_files != "" ? var.build_ignored_files : ["helm/**", "deploy.yaml", "stage.yaml"]
  stage_ignored_files = var.stage_ignored_files != "" ? var.stage_ignored_files : ["deploy.yaml", "build.yaml"]
  deploy_ignored_files = var.deploy_ignored_files != "" ? var.deploy_ignored_files : ["build.yaml", "stage.yaml"]

}

resource "google_cloudbuild_trigger" "build-trigger" {
  name     = local.build_name
  filename = local.build_file
  project  = var.project_id
  service_account = "projects/moove-builds-a747/serviceAccounts/builder@moove-builds-a747.iam.gserviceaccount.com"

  included_files = local.build_included_files
  ignored_files = local.build_ignored_files

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.build_branch_pattern
    }
  }
}

resource "google_cloudbuild_trigger" "stage-trigger" {
  name     = local.stage_name
  filename = local.stage_file
  project  = var.project_id
  service_account = "projects/moove-builds-a747/serviceAccounts/deployer@moove-builds-a747.iam.gserviceaccount.com"

  included_files = local.stage_included_files
  ignored_files = local.stage_ignored_files

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.stage_branch_pattern
    }
  }
}

resource "google_cloudbuild_trigger" "deploy-trigger" {
  name     = local.deploy_name
  filename = local.deploy_file
  project  = var.project_id
  service_account = "projects/moove-builds-a747/serviceAccounts/deployer@moove-builds-a747.iam.gserviceaccount.com"

  included_files = local.deploy_included_files
  ignored_files = local.deploy_ignored_files

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.deploy_branch_pattern
    }
  }
}