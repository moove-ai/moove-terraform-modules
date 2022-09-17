data "google_service_account" "sa" {
  project    = var.project_id
  account_id = var.service_account
}


resource "google_cloudbuild_trigger" "trigger" {
  project         = var.project_id
  location        = var.location
  name            = var.build_name
  description     = var.build_description
  service_account = data.google_service_account.sa.name
  filename        = var.cloudbuild_filename
  included_files  = var.included_files
  ignored_files   = var.ignored_files

  tags = concat(var.tags, [
    "build",
  ])


  github {
    owner = "moove-ai"
    name  = var.git_repo

    push {
      branch = "^${var.build_branch}$"
    }
  }

  substitutions = {
    _ENVIRONMENT = var.environment
  }

}
