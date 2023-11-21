module "gke-app" {
  source = "../../gke-app"

  create_service_account       = var.create_service_account
  service_account_display_name = var.service_account_display_name
  service_account_description  = var.service_account_description
  service_account_id           = var.service_account_id
  gke_project_id               = var.gke_project_id
  environment                  = var.environment
  gke_service_account_name     = var.gke_service_account_name
  project_id                   = var.project_id
}

resource "google_bigtable_instance_iam_member" "user" {
  depends_on = [module.gke-app]

  instance = var.bigtable_instance_name
  project  = var.project_id
  role     = "roles/bigtable.user"
  member   = module.gke-app.service_account_member
}

resource "google_bigtable_instance_iam_member" "reader" {
  depends_on = [module.gke-app]

  instance = var.bigtable_instance_name
  project  = var.project_id
  role     = "roles/bigtable.reader"
  member   = module.gke-app.service_account_member
}

resource "google_bigtable_instance_iam_member" "gke-user" {
  depends_on = [module.gke-app]

  instance = var.bigtable_instance_name
  project  = var.project_id
  role     = "roles/bigtable.user"
  member   = module.gke-app.service_account_member
}

resource "google_bigtable_instance_iam_member" "gke-reader" {
  depends_on = [module.gke-app]

  instance = var.bigtable_instance_name
  project  = var.project_id
  role     = "roles/bigtable.reader"
  member   = module.gke-app.service_account_member
}
