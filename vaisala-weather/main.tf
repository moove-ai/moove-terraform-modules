resource "google_cloudfunctions_function_iam_member" "vaisala_ingest" {
  for_each = toset(var.project_list)

  project        = each.value
  region         = var.region
  cloud_function = "vaisala_ingest"
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.serviceaccount}"
}

resource "google_cloudfunctions_function_iam_member" "secrets" {
  project        = "moove-road-iq-staging"
  region         = var.region
  cloud_function = "fetch_secrets"
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.serviceaccount}"
}

resource "google_cloudfunctions_function_iam_member" "vaisala-normalization" {
  for_each = toset(var.project_list)

  project        = each.value
  region         = var.region
  cloud_function = "vaisala_normalization"
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.serviceaccount}"
}

resource "google_cloudfunctions_function_iam_member" "vaisala_coordinator_partitioned" {
  for_each = toset(var.project_list)

  project        = each.value
  region         = var.region
  cloud_function = "vaisala_coordinator_partitioned"
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.composer_serviceaccount}"
}

resource "google_storage_bucket_iam_member" "vaisala_weather-iam" {
  bucket = "vaisala_weather"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.function_serviceaccount}"

}

data "google_service_account" "appspot" {
  for_each   = toset(var.project_list)
  account_id = "${each.value}@appspot.gserviceaccount.com"
}

data "google_service_account" "function" {
  for_each   = toset(var.project_list)
  account_id = var.function_serviceaccount
}

resource "google_service_account_iam_member" "gce-default-account-iam" {
  for_each           = toset(var.project_list)
  service_account_id = data.google_service_account.appspot[each.value].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.composer_serviceaccount}"
}

resource "google_service_account_iam_member" "function-account-iam" {
  for_each           = toset(var.project_list)
  service_account_id = data.google_service_account.function[each.value].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.composer_serviceaccount}"
}

resource "google_secret_manager_secret_iam_member" "vaisala_api_kkey" {
  project   = "moove-secrets"
  secret_id = "vaisala_api_key"
  member    = "serviceAccount:${var.function_serviceaccount}"
}
