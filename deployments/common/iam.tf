# Depends on moove-terraform/mgmt/secrets/deployments being deployed

data "google_secret_manager_secret" "github-token" {
  secret_id = "ci-cd_github-token"
  project = var.secret_project_id
}

data "google_secret_manager_secret" "grafana-api-key" {
  secret_id = "ci-cd_grafana-token"
  project = var.secret_project_id
}

data "google_secret_manager_secret" "slack-webhook-token" {
  secret_id = "ci-cd_slack-webhook-token-cf-build-notification"
  project = var.secret_project_id
}

resource "google_secret_manager_secret_iam_member" "privileged-builder-grafana-iam" {
  project = data.google_secret_manager_secret.grafana-api-key.project
  secret_id = data.google_secret_manager_secret.grafana-api-key.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_secret_manager_secret_iam_member" "privileged-builder-slack-iam" {
  project = data.google_secret_manager_secret.slack-webhook-token.project
  secret_id = data.google_secret_manager_secret.slack-webhook-token.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.privileged-builder.email}"
}

resource "google_secret_manager_secret_iam_member" "privileged-builder-github-token-iam" {
  project = data.google_secret_manager_secret.github-token.project
  secret_id = data.google_secret_manager_secret.github-token.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.privileged-builder.email}"
}
