module "gke-app" {
  source = "../gke-app"

  create_serviceaccount       = var.create_serviceaccount
  serviceaccount_display_name = var.serviceaccount_display_name
  serviceaccount_description  = var.serviceaccount_description
  serviceaccount_id           = var.serviceaccount_id
  gke_project_id              = var.gke_project_id
  environment                 = var.environment
  gke_serviceaccount_name     = var.gke_serviceaccount_name
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
