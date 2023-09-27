resource "google_organization_iam_member" "atlantis-admin" {
  org_id = var.org_id
  role   = "roles/owner"
  member = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_organization_iam_member" "atlantis-org-admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.organizationAdmin"
  member = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_organization_iam_member" "atlantis-org-role-admin" {
  org_id = var.org_id
  role   = "roles/iam.organizationRoleAdmin"
  member = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_organization_iam_member" "atlantis-project-iam-admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.projectIamAdmin"
  member = "serviceAccount:${google_service_account.atlantis.email}"
}
