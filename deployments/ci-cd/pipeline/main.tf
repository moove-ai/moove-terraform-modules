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

resource "google_cloudbuild_trigger" "deploy-trigger" {
  name     = local.deploy_name
  filename = local.deploy_file
  project  = var.project_id
  service_account = "projects/moove-builds-a747/serviceAccounts/deployer@moove-builds-a747.iam.gserviceaccount.com"

  included_files = local.deploy_included_files
  ignored_files = local.deploy_ignored_files

  substitutions = {
    _CLUSTER_PROJECT = var.cluster_project
    _ENVIRONMENT = var.environment
    _REGION = var.region
  }

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.deploy_branch_pattern
    }
  }
}
