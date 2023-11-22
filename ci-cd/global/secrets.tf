resource "google_secret_manager_secret" "cicd-slack-hook" {
  project   = "moove-secrets"
  secret_id = "cicd-slack-deploys-hook"

  labels = {
    environment   = "mgmt"
    function      = "cicd"
    slack_channel = "deploys"
    client        = "moove"
    terraformed   = "true"
    secret-data   = "manual-input"
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "cicd-slack-hook-iam-member" {
  project   = google_secret_manager_secret.cicd-slack-hook.project
  secret_id = google_secret_manager_secret.cicd-slack-hook.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_secret_manager_secret" "grafana-api-key" {
  project   = var.secret_project_id
  secret_id = "ci-cd_grafana-token"

  labels = {
    function    = "cloudbuild"
    application = "cloudfunctions"
    environment = var.environment
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "github-token" {
  project   = var.secret_project_id
  secret_id = "ci-cd_github-token"

  labels = {
    function    = "cloudbuild"
    application = "cloudfunctions"
    environment = var.environment
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    auto {}
  }
}
