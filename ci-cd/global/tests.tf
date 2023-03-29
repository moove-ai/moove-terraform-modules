resource "google_service_account" "test" {
  project      = module.builds.project_id
  account_id   = "build-tests"
  display_name = "Build tests"
  description  = "service account with no permissions used for testing"
}

resource "google_service_account_key" "test-key" {
  service_account_id = google_service_account.test.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}


resource "google_secret_manager_secret" "build-tests" {
  project   = "moove-secrets"
  secret_id = "ci_cd-test-service-account"

  labels = {
    function    = "cicd"
    client      = "moove"
    terraformed = "true"
    secret-data = "terraform"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret      = google_secret_manager_secret.test-key.id
  secret_data = base64decode(google_service_account.test.private_key)
}

resource "google_secret_manager_secret_iam_member" "test-key-iam-member" {
  project   = google_secret_manager_secret.build-tests.project
  secret_id = google_secret_manager_secret.build-tests.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}
