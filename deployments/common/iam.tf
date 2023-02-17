# Depends on moove-terraform/mgmt/secrets/deployments being deployed

data "google_secret_manager_secret" "github-token" {
  secret_id = "ci-cd_github-token"
  project   = var.secret_project_id
}

data "google_secret_manager_secret" "grafana-api-key" {
  secret_id = "ci-cd_grafana-token"
  project   = var.secret_project_id
}

data "google_secret_manager_secret" "slack-webhook-token" {
  secret_id = "ci-cd_slack-webhook-token-cf-build-notification"
  project   = var.secret_project_id
}

data "google_secret_manager_secret" "argocd-ssh-key" {
  secret_id = "argocd_ssh-key"
  project   = var.secret_project_id
}

data "google_service_account" "terraform" {
  project    = "moove-systems"
  account_id = "terraform"
}

resource "google_project_iam_custom_role" "builder" {
  project     = var.project_id
  role_id     = "builder"
  title       = "Builder"
  description = "Role with minimum permissions needed for a builder"
  permissions = [
    "storage.buckets.create",
    "logging.logEntries.create",
    "storage.buckets.get",
  ]
}

resource "google_project_iam_member" "builder-iam" {
  project = var.project_id
  role    = google_project_iam_custom_role.builder.name
  member  = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_project_iam_member" "privileged-builder-iam" {
  project = var.project_id
  role    = google_project_iam_custom_role.builder.name
  member  = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_project_iam_member" "builder-registry-iam" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_project_iam_member" "privileged-builder-registry-iam" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_project_iam_member" "privileged-builder-k8s" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_secret_manager_secret_iam_member" "privileged-builder-devops-ssh-key-iam" {
  project   = data.google_secret_manager_secret.devops-ssh-key.project
  secret_id = data.google_secret_manager_secret.devops-ssh-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.privileged-builder.email}"
}


resource "google_secret_manager_secret_iam_member" "privileged-builder-grafana-iam" {
  project   = data.google_secret_manager_secret.grafana-api-key.project
  secret_id = data.google_secret_manager_secret.grafana-api-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_secret_manager_secret_iam_member" "privileged-builder-slack-iam" {
  project   = data.google_secret_manager_secret.slack-webhook-token.project
  secret_id = data.google_secret_manager_secret.slack-webhook-token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_secret_manager_secret_iam_member" "privileged-builder-github-token-iam" {
  project   = data.google_secret_manager_secret.github-token.project
  secret_id = data.google_secret_manager_secret.github-token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_storage_bucket_iam_member" "privileged-builder-logs-iam" {
  bucket = google_storage_bucket.build-logs.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_storage_bucket_iam_member" "builder-logs-iam" {
  bucket = google_storage_bucket.build-logs.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_storage_bucket_iam_member" "privileged-builder-cache-iam" {
  bucket = google_storage_bucket.build-cache.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_storage_bucket_iam_member" "builder-cache-iam" {
  bucket = google_storage_bucket.build-cache.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_storage_bucket_iam_member" "privileged-builder-registry-iam" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_storage_bucket_iam_member" "builder-registry-iam" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_storage_bucket_iam_member" "privileged-builder-admin-registry-iam" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_storage_bucket_iam_member" "builder-registry-admin-iam" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_service_account_iam_member" "builder-act-as" {
  service_account_id = data.google_service_account.terraform.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_service_account_iam_member" "p-builder-act-as" {
  service_account_id = data.google_service_account.terraform.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.privileged-builder.email}"
}
