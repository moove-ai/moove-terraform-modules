resource "google_bigquery_dataset_access" "access" {
  for_each      = toset(var.email_list)
  project       = var.project_id
  dataset_id    = var.shared_dataset
  role          = "roles/bigquery.dataViewer"
  user_by_email = each.key
}