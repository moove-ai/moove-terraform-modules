data "google_secret_manager_secret" "alertmanager_pager-duty-api-key" {
    project = "moove-secrets"
    secret_id = "alertmanager_pager-duty-api-key"
}

data "google_secret_manager_secret" "alertmanager_slack-alerts-key" {
    project = "moove-secrets"
    secret_id = "alertmanager_slack-alerts-key"
}

data "google_secret_manager_secret" "alertmanager_slack-staging-key" {
    project = "moove-secrets"
    secret_id = "alertmanager_slack-staging-key"
}


resource "google_secret_manager_secret_iam_member" "alertmanager-api-key-secret-iam" {
  project = "moove-secrets"
  secret_id = data.google_secret_manager_secret.alertmanager_pager-duty-api-key.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.k8s-secrets.email}"
}

resource "google_secret_manager_secret_iam_member" "alertmanager_slack-alerts-key-iam" {
  project = "moove-secrets"
  secret_id = data.google_secret_manager_secret.alertmanager_slack-alerts-key.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.k8s-secrets.email}"
}

resource "google_secret_manager_secret_iam_member" "alertmanager_slack-staging-key-iam" {
  project = "moove-secrets"
  secret_id = data.google_secret_manager_secret.alertmanager_slack-staging-key.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.k8s-secrets.email}"
}
