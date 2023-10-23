resource "google_service_account" "serviceaccount" {
  count = var.create_serviceaccount ? 1 : 0

  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.serviceaccount_display_name
  description  = var.serviceaccount_description
}

data "google_service_account" "serviceaccount" {
  count = var.create_serviceaccount ? 0 : 1

  project    = var.project_id
  account_id = var.serviceaccount_id
}

resource "google_bigtable_instance_iam_member" "user" {
  instance = var.bigtable_instance_name
  project  = var.bigtable_project_id
  role     = "roles/bigtable.user"
  member   = var.create_serviceaccount ? google_service_account.serviceaccount[0].member : data.google_service_account.my_service_account.member
}

resource "google_bigtable_instance_iam_member" "reader" {
  instance = var.bigtable_instance_name
  project  = var.bigtable_project_id
  role     = "roles/bigtable.reader"
  member   = var.create_serviceaccount ? google_service_account.serviceaccount[0].member : data.google_service_account.my_service_account.member
}

resource "google_bigtable_instance_iam_member" "gke-user" {
  instance = var.bigtable_instance_name
  project  = var.bigtable_project_id
  role     = "roles/bigtable.user"
  member   = var.create_serviceaccount ? google_service_account.serviceaccount[0].member : data.google_service_account.my_service_account.member
}

resource "google_bigtable_instance_iam_member" "gke-reader" {
  instance = var.bigtable_instance_name
  project  = var.bigtable_project_id
  role     = "roles/bigtable.reader"
  member   = var.create_serviceaccount ? google_service_account.serviceaccount[0].member : data.google_service_account.my_service_account.member
}
