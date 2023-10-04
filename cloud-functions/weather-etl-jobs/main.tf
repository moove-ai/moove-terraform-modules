data "google_service_account" "function_sa" {
  for_each   = var.environments
  account_id = each.value.function_service_account
  project    = each.value.function_service_account_project
}

data "google_service_account" "build_sa" {
  account_id = var.build_service_account
  project    = var.build_service_account_project
}

resource "google_service_account_iam_member" "service_account_deployer-function" {
  for_each           = var.environments
  service_account_id = data.google_service_account.function_sa[each.key].id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_service_account.build_sa.email}"
}

resource "google_service_account_iam_member" "service_account_user-function" {
  for_each           = var.environments
  service_account_id = data.google_service_account.build_sa.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_service_account.function_sa[each.key].email}"
}

