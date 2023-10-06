resource "google_composer_environment" "composer_env" {
  project = var.composer_project_id
  name    = var.composer_environment
}

resource "google_cloudbuild_trigger" "build" {
  name            = var.build_name
  location        = "global"
  project         = var.build_project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"
  included_files  = var.build_included_files
  ignored_files   = var.build_ignored_files
  tags            = var.build_tags
  disabled        = var.disable_trigger

  filename = var.build_file

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.build_branch_pattern
    }
  }

  substitutions = merge(
    {
      _DAG_BAG = google_composer_environment.config.0.dag_gcs_prefix
    }
    , var.addiotnal_build_substitions
  )
}
