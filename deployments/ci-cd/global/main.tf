# Project
module "builds" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.1"

  name                    = "moove-builds"
  random_project_id       = true
  org_id                  = var.org_id
  billing_account         = var.billing_account
  folder_id               = var.folder_id
  default_service_account = "delete"
  auto_create_network     = false
  activate_apis           = var.apis
  svpc_host_project_id    = "moove-systems"
}

# Logging
resource "google_storage_bucket" "logs" {
  depends_on = [module.builds]

  project  = module.builds.project_id
  name     = "moove-build-logs"
  location = "US"

  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type = "Delete"
    }
  }
}

# Builder
resource "google_service_account" "builder" {
  depends_on = [module.builds]

  account_id   = "builder"
  display_name = "Cloud Build Builder"
  description  = "CI/CD Pipeline. Used in the build step."
  project      = module.builds.project_id
}

resource "google_project_iam_custom_role" "builder" {
  depends_on = [module.builds]

  project     = module.builds.project_id
  role_id     = "builder"
  title       = "Builder"
  description = "Role with minimum permissions needed for a builder"
  permissions = [
    "storage.buckets.create",
    "logging.logEntries.create",
    "storage.buckets.get",
  ]
}

resource "google_project_iam_member" "builder-iam" {
  depends_on = [module.builds]

  project = module.builds.project_id
  role    = google_project_iam_custom_role.builder.name
  member  = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_project_iam_member" "builder-registry-iam" {
  depends_on = [module.builds]

  project = module.builds.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.builder.email}"
}

# Deployer
resource "google_service_account" "deployer" {
  depends_on = [module.builds]

  account_id   = "deployer"
  display_name = "Cloud Build Deployer"
  description  = "CI/CD Pipeline. Used in the deploy steps."
  project      = module.builds.project_id
}

resource "google_project_iam_member" "deployer-iam" {
  depends_on = [module.builds]

  project = module.builds.project_id
  role    = google_project_iam_custom_role.builder.name
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deplpyer-registry-iam" {
  depends_on = [module.builds]
  project    = module.builds.project_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer-container-iam" {
  for_each   = toset(var.k8s_projects)
  depends_on = [module.builds]
  project    = each.key
  role       = "roles/container.developer"
  member     = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_secret_manager_secret_iam_member" "member" {
  project   = "moove-secrets"
  secret_id = "projects/moove-secrets/secrets/ci-cd_github-token"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}