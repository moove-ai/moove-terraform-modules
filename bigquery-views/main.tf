/**
 * # Bigquery Views
 *
 * Creates Bigquery Views.
 *
 * [Views](https://cloud.google.com/bigquery/docs/views-intro)
 * 
 * Written by Alex Merenda for moove.ai
 */

locals {
  views = { for view in var.views : view["view_id"] => view }
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.shared_dataset
  project    = var.project_id
}

resource "google_bigquery_table" "view" {
  for_each      = local.views
  dataset_id    = google_bigquery_dataset.dataset.dataset_id
  friendly_name = each.key
  table_id      = each.key
  labels        = each.value["labels"]
  project       = var.project_id

  lifecycle {
    prevent_destroy = "false"
  }

  view {
    query          = each.value["query"]
    use_legacy_sql = each.value["use_legacy_sql"]
  }
  depends_on = [google_bigquery_dataset.dataset]
}

resource "google_bigquery_dataset_access" "dataset-access" {
  project    = var.shared_dataset_project
  for_each   = local.views
  dataset_id = var.shared_dataset
  view {
    project_id = google_bigquery_table.view[each.key].project
    dataset_id = google_bigquery_table.view[each.key].dataset_id
    table_id   = google_bigquery_table.view[each.key].table_id
  }
  depends_on = [google_bigquery_table.view]
}
