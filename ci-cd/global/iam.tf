data "google_service_account" "k8s-nodes" {
  for_each   = toset(var.k8s_projects)
  account_id = "k8s-nodes"
  project    = each.key
}

resource "google_project_iam_member" "k8s-nodes-reader-iam" {
  for_each = toset(var.k8s_projects)
  project  = module.builds.project_id
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${data.google_service_account.k8s-nodes[each.key].email}"
}

resource "google_project_iam_member" "k8s-nodes-object-viewer-iam" {
  for_each = toset(var.k8s_projects)
  project  = module.builds.project_id
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${data.google_service_account.k8s-nodes[each.key].email}"
}

resource "google_project_iam_member" "deployer-deploys" {
  project = module.builds.project_id
  role    = "roles/clouddeploy.operator"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer-gcs-admin" {
  for_each = toset(var.run_projects)
  project  = each.key
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer-container-admin" {
  for_each = toset(var.k8s_projects)
  project  = each.key
  role     = "roles/container.admin"
  member   = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_custom_role" "deployer" {
  project     = module.builds.project_id
  role_id     = "deployer"
  title       = "Deployer Role"
  description = "Role that provides the 'storage.buckets.list' permission"
  permissions = ["storage.buckets.list"]
}

resource "google_project_iam_member" "member" {
  project = module.builds.project_id
  role    = google_project_iam_custom_role.deployer.id
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "service_account_user" {
  project = module.builds.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}
