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
