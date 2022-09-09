resource "google_secret_manager_secret" "grafana-api-key" {
  secret_id = "ci-cd_grafana-token"

  labels = {
    function = "cloudbuild"
    application = "cloudfunctions"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "slack-webhook-token" {
  secret_id = "ci-cd_slack-webhook-token-cf-build-notification"

  labels = {
    function = "cloudbuild"
    application = "cloudfunctions"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "builder-grafana-iam" {
  project = google_secret_manager_secret.grafana-api-key.project
  secret_id = google_secret_manager_secret.grafana-api-key.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_secret_manager_secret_iam_member" "builder-slack-iam" {
  project = google_secret_manager_secret.slack-webhook-token.project
  secret_id = google_secret_manager_secret.slack-webhook-token.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.builder.email}"
}
