module "builds" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 9.1"

  name                 = "moove-builds"
  random_project_id    = false
  org_id               = var.org_id
  billing_account      = var.billing_account
  folder_id            = var.folder_id
  auto_create_network  = false
  activate_apis        = var.apis
}

resource "google_service_account" "builder" {
  depends_on = [module.builds]

  account_id   = "builder"
  display_name = "Cloud Build Builder"
  description  = "CI/CD Pipeline. Used in the build step."
  project      = module.builds.project_id
}

resource "google_project_iam_custom_role" "builder" {
  depends_on = [module.builds]

  project      = module.builds.project_id
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

  project      = module.builds.project_id
  role    = google_project_iam_custom_role.builder.name
  member  = "serviceAccount:${google_service_account.builder.email}"
}

resource "google_project_iam_member" "builder-registry-iam" {
  depends_on = [module.builds]

  project      = module.builds.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.builder.email}"
}