data "google_service_account" "cloudbuild-sa" {
    project = var.cloud_build_project_id
    account_id = var.cloud_build_service_account
}

resource "google_project_iam_member" "composer-storage-admin" {
    for_each = toset(var.composer_projects)
    project = each.key
    role = "roles/composer.environmentAndStorageObjectAdmin"
    member = data.google_service_account.cloudbuild-sa.member
}

resource "google_project_iam_member" "composer-worker" {
    for_each = toset(var.composer_projects)
    project = each.key
    role = "roles/composer.worker"
    member = data.google_service_account.cloudbuild-sa.member
}

resource "google_cloudbuild_trigger" "pre-merge" {
  name               = "test-dag-deployments"
  description        = "Trigger to run pre-merge hooks on DAGs"
  filename           = "cloudbuild/pre-merge.yaml"
  project            = var.cloud_build_project_id
}