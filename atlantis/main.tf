## Service Account
resource "google_service_account" "atlantis" {
  project      = var.project_id
  account_id   = "k8s-atlantis"
  display_name = "Atlantis"
  description  = "Service account that runs Atlantis"
}

## Secrets
resource "google_secret_manager_secret" "atlantis_git-config-secret" {
  project   = var.secret_project_id
  secret_id = "atlantis_git-config-secret"

  labels = {
    environment = var.environment
    function    = "atlantis"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "atlantis_github-token" {
  project   = var.secret_project_id
  secret_id = "atlantis_github-token"

  labels = {
    environment = var.environment
    function    = "atlantis"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "atlantis_github-secret" {
  project   = var.secret_project_id
  secret_id = "atlantis_github-secret"

  labels = {
    environment = var.environment
    function    = "atlantis"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

## Secrets IAM
resource "google_secret_manager_secret_iam_member" "atlantis_git-config-secret-iam" {
  project = google_secret_manager_secret.atlantis_git-config-secret.project
  secret_id = google_secret_manager_secret.atlantis_git-config-secret.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:k8s-secrets@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "atlantis_github-token-iam" {
  project = google_secret_manager_secret.atlantis_github-token.project
  secret_id = google_secret_manager_secret.atlantis_github-token.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:k8s-secrets@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "atlantis_github-secret-iam" {
  project = google_secret_manager_secret.atlantis_github-secret.project
  secret_id = google_secret_manager_secret.atlantis_github-secret.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:k8s-secrets@${var.project_id}.iam.gserviceaccount.com"
}
