resource "google_cloudbuild_trigger" "build" {
  name            = var.build_name
  location        = "global"
  project         = var.project_id
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

  substitutions = var.substitutions
}
