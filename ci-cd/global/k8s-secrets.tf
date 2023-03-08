data "google_service_account" "secrets" {
  for_each   = toset(var.k8s_projects)
  project    = each.key
  account_id = "k8s-secrets"
}

resource "google_secret_manager_secret" "argocd-grafana-key" {
  project   = "moove-secrets"
  secret_id = "argocd_grafana-api-key"

  labels = {
    environment = "mgmt"
    function    = "argocd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "argocd-slack-token" {
  project   = "moove-secrets"
  secret_id = "argocd_slack-token"

  labels = {
    environment = "mgmt"
    function    = "argocd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "argocd-slack-token-iam-member" {
  for_each  = toset(var.k8s_projects)
  project   = google_secret_manager_secret.argocd-slack-token.project
  secret_id = google_secret_manager_secret.argocd-slack-token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.secrets[each.key].email}"
}

resource "google_secret_manager_secret_iam_member" "argocd-grafana-key-iam-member" {
  for_each  = toset(var.k8s_projects)
  project   = google_secret_manager_secret.argocd-grafana-key.project
  secret_id = google_secret_manager_secret.argocd-grafana-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_service_account.secrets[each.key].email}"
}
