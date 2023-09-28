/**
 * # Atlantis
 *
 * Creates Atlantis resources.
 *
 * [Atlantis](https://www.runatlantis.io/)
 * 
 * Written by Alex Merenda for moove.ai
 * 
 * ## Instructions:
 * ## DO STEP 1 BEFORe APPLY
 * 
 * 1. Create a secret called `atlantis_github-token` in the `moove-secrts` project with a GitHub personal access token from the `moove-devopsbot` account. 
 *    Ensure the token has the following scopes:
 *    - `repo` (for private repos) or `public_repo` (for public repos)
 *    - `read:org` (optional, for certain Atlantis configurations)
 *    - `write:discussion` (optional, for team discussions)
 *    - `admin:repo_hook` (for webhook creation)
 *  2. Modify the `moove-terraform` webhook to use the value stored in the secret `atlantis_github-secret` in the `moove-secrets` project.
 * 
 */

resource "google_service_account" "atlantis" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "Atlantis"
  description  = "Service account that runs Atlantis"
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
    auto {}
  }
}

resource "random_string" "git" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "google_secret_manager_secret_version" "atlantis_github-secret-version" {
  enabled         = true
  deletion_policy = "DISABLE"
  secret          = google_secret_manager_secret.atlantis_github-secret.id
  secret_data     = random_string.git.result
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
    auto {}
  }
}

resource "google_service_account_key" "atlantis-key" {
  service_account_id = google_service_account.atlantis.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_secret_manager_secret_version" "atlantis_key" {
  enabled         = true
  secret          = google_secret_manager_secret.atlantis_gcp-sa-key.id
  secret_data     = base64decode(google_service_account_key.atlantis-key.private_key)
  deletion_policy = "DISABLE"
}

data "google_secret_manager_secret" "atlantis_github-token" {
  project   = "moove-secrets"
  secret_id = "atlantis_github-token"
}

data "google_secret_manager_secret_version" "atlantis_github-token-version" {
  project = data.google_secret_manager_secret.atlantis_github-token.project
  secret  = data.google_secret_manager_secret.atlantis_github-token.secret_id
}

## Secrets IAM
resource "google_secret_manager_secret_iam_member" "atlantis_github-token-iam" {
  project   = data.google_secret_manager_secret.atlantis_github-token.project
  secret_id = data.google_secret_manager_secret.atlantis_github-token.secret_id
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
