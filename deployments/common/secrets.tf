resource "google_secret_manager_secret" "ci-cd_argocd-user" {
  project   = var.project_id
  secret_id = "ci-cd_argocd-user"

  labels = {
    environment = var.environment
    function    = "ci-cd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "ci-cd_argocd-password" {
  project   = var.project_id
  secret_id = "ci-cd_argocd-password"

  labels = {
    environment = var.environment
    function    = "ci-cd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "user" {
  project   = google_secret_manager_secret.ci-cd_argocd-user.project
  secret_id = google_secret_manager_secret.ci-cd_argocd-user.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:privileged-builder@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "password" {
  project   = google_secret_manager_secret.ci-cd_argocd-password.project
  secret_id = google_secret_manager_secret.ci-cd_argocd-password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:privileged-builder@${var.project_id}.iam.gserviceaccount.com"
}
