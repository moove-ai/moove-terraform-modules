## Service Account
resource "google_service_account" "atlantis" {
  project      = var.project_id
  account_id   = "k8s-atlantis"
  display_name = "Atlantis"
  description  = "Service account that runs Atlantis"
}


## Secrets
resource "google_secret_manager_secret" "atlantis_github-user" {
  project   = var.secret_project_id
  secret_id = "atlantis_github-user"

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
