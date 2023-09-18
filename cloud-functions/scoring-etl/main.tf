locals {
  build_included_files = var.build_included_files != [] ? var.build_included_files : ["${var.function_name}/**"]
  build_file           = var.build_file != "" ? var.build_file : "${var.function_name}/cloudbuild.yaml"
  build_tags           = [var.github_repo, "deplpy", "scoring-etl-jobs", "cloud-function"]
  roles_list           = concat(["roles/cloudfunctions.invoker", "roles/iam.serviceAccountUser"], var.function_additional_roles)
  env_role_combinations = flatten([
    for env_key, env_value in var.environments : [
      for role in local.roles_list : {
        env_key    = env_key
        project_id = env_value.project_id
        role       = role
      }
    ]
  ])
}

data "google_service_account" "scoring" {
  for_each   = var.environments
  project    = each.value.project_id
  account_id = var.service_account_id
}

data "google_service_account" "deployer" {
  project    = var.build_project_id
  account_id = var.build_service_account_id
}

resource "google_project_iam_member" "scoring-iam" {
  for_each = { for combo in local.env_role_combinations : "${combo.env_key}-${combo.role}" => combo }
  project  = each.value.project_id
  role     = each.value.role
  member   = "serviceAccount:${data.google_service_account.scoring[each.value.env_key].email}"
}

resource "google_service_account_iam_member" "deployer-act-as" {
  for_each           = var.environments
  service_account_id = data.google_service_account.scoring[each.key].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_service_account.deployer.email}"
}

resource "google_cloudbuild_trigger" "deploy" {
  for_each        = var.environments
  name            = "deploy-${var.function_name}-${each.key}-${each.value.region}"
  location        = var.build_location
  project         = var.build_project_id
  service_account = data.google_service_account.deployer.id
  included_files  = local.build_included_files
  ignored_files   = var.build_ignored_files
  tags            = concat(var.build_tags, local.build_tags, [each.key], [each.value.region])
  description     = "Deploy the ${var.function_name} function to ${each.key} ${each.value.region}"

  filename = local.build_file

  substitutions = {
    _FUNCTION_NAME            = var.function_name
    _FUNCTION_REGION          = each.value.region
    _FUNCTION_ENVIRONMENT     = each.key
    _FUNCTION_PROJECT_ID      = each.value.project_id
    _FUNCTION_SERVICE_ACCOUNT = data.google_service_account.scoring[each.key].email
  }

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = each.value.build_branch_pattern
    }
  }
}
