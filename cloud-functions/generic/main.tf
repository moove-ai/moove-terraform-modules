locals {
  build_included_files = var.build_included_files != [] ? var.build_included_files : ["**"]
  build_ignored_files  = var.build_ignored_files != [] ? var.build_ignored_files : ["README.md"]
  build_file           = var.build_file != "" ? var.build_file : "cloudbuild.yaml"
  build_tags           = [var.github_repo, "cloud-function", "terraform"]
}

data "google_service_account" "deployer" {
  project    = var.build_project_id
  account_id = var.build_service_account_id
}

data "google_service_account" "function" {
  for_each   = var.environments
  project    = each.value.project_id
  account_id = var.service_account_id
}

resource "google_cloudbuild_trigger" "deploy" {
  for_each        = var.environments
  name            = "deploy-cf-${replace(var.function_name, "_", "-")}-${each.key}"
  location        = var.build_location
  project         = var.build_project_id
  service_account = data.google_service_account.deployer.id
  included_files  = local.build_included_files
  ignored_files   = local.build_ignored_files
  tags            = concat(var.build_tags, local.build_tags, [each.key, each.value.region, each.value.cloud_function_function])
  description     = "Deploy the ${var.function_name} function to ${each.key} ${each.value.region}"

  filename = local.build_file

  substitutions = merge({
    _FUNCTION_NAME             = var.function_name
    _FUNCTION_REGION           = each.value.region
    _FUNCTION_ENVIRONMENT      = each.key
    _FUNCTION_PROJECT_ID       = each.value.project_id
    _FUNCTION_SERVICE_ACCOUNT  = data.google_service_account.function[each.key].email
    _FUNCTION_ENVIRONMENT_VARS = join(",", [for k, v in each.value.function_env_vars : "${k}=${v}"])
  }, var.build_additional_substitutions)

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = each.value.build_branch_pattern
    }
  }
}
