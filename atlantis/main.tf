/**
 * # Atlantis
 *
 * Creates Atlantis resources.
 *
 * [Atlantis](https://www.runatlantis.io/)
 * 
 * Written by Alex Merenda for moove.ai
 */


resource "google_service_account" "atlantis" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Atlantis"
  description  = "Service account that runs Atlantis"
}

#data "google_service_account" "terraform" {
#  project    = "moove-systems"
#  account_id = "terraform"
#}

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

resource "google_secret_manager_secret_version" "atlantis_git-config-secret-version" {
  secret = google_secret_manager_secret.atlantis_git-config-secret.secret_id

  secret_data = "REPLACE MANUALLY WITH GIT CONFIG DATA"

  lifecycle {
    ignore_changes = [secret_data]
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

resource "google_secret_manager_secret_version" "atlantis_github-token-version" {
  secret = google_secret_manager_secret.atlantis_github-token.secret_id

  secret_data = "REPLACE MANUALLY WITH A GITHUB TOKEN FOR THE ATLANTIS GITHUB USER"

  lifecycle {
    ignore_changes = [secret_data]
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

resource "google_secret_manager_secret_version" "atlantis_github-secret-version" {
  secret = google_secret_manager_secret.atlantis_github-secret.secret_id

  secret_data = "REPLACE MANUALLY WITH A GITHUB SECRET TO AUTHENTICATE THE GITHUB WEBHOOK"

  lifecycle {
    ignore_changes = [secret_data]
  }
}


resource "google_secret_manager_secret" "atlantis_gcp-sa-key" {
  project   = var.secret_project_id
  secret_id = "atlantis_gcp-sa-key"

  labels = {
    environment = var.environment
    function    = "atlantis"
    client      = "moove"
    terraformed = "true"
    secret-data = "terraformed"
  }

  replication {
    automatic = true
  }
}

resource "google_service_account_key" "atlantis-key" {
  service_account_id = google_service_account.atlantis.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

#resource "google_service_account_key" "terraform" {
#  service_account_id = data.google_service_account.terraform.name
#  public_key_type    = "TYPE_X509_PEM_FILE"
#}

#resource "google_secret_manager_secret_version" "atlantis_gcp-sa-key-data" {
#  secret      = google_secret_manager_secret.atlantis_gcp-sa-key.id
#  secret_data = base64decode(google_service_account_key.terraform.private_key)
#}

## Secrets IAM
resource "google_secret_manager_secret_iam_member" "atlantis_git-config-secret-iam" {
  project   = google_secret_manager_secret.atlantis_git-config-secret.project
  secret_id = google_secret_manager_secret.atlantis_git-config-secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_secret_manager_secret_iam_member" "atlantis_github-token-iam" {
  project   = google_secret_manager_secret.atlantis_github-token.project
  secret_id = google_secret_manager_secret.atlantis_github-token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_secret_manager_secret_iam_member" "atlantis_github-secret-iam" {
  project   = google_secret_manager_secret.atlantis_github-secret.project
  secret_id = google_secret_manager_secret.atlantis_github-secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_secret_manager_secret_iam_member" "atlantis_gcp-sa-key-iam" {
  project   = google_secret_manager_secret.atlantis_gcp-sa-key.project
  secret_id = google_secret_manager_secret.atlantis_gcp-sa-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.atlantis.email}"
}
