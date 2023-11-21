# Path: moove-terraform-modules/applications/prometheus-bigquery-exporter/main.tf
locals {
  bigquery_project_id = var.bigquery_project_id != "" ? var.bigquery_project_id : var.project_id
  k8s_cluster_project = var.k8s_cluster_project != "" ? var.k8s_cluster_project : var.project_id
  k8s_namespace       = var.k8s_namespace != "" ? var.k8s_namespace : var.environment
  app_name            = "prometheus-bigquery-exporter"
}


module "service_account" {
  source = "../../service-account"

  project_id   = var.project_id
  description  = var.service_account_description
  display_name = var.service_account_display_name
  account_id   = var.service_account_id
}

resource "google_bigquery_dataset" "dataset" {
  depends_on = [module.service_account]

  project                     = var.project_id
  dataset_id                  = var.bigquery_dataset_id
  friendly_name               = var.bigquery_dataset_friendly_name
  description                 = var.bigquery_dataset_description
  location                    = var.bigquery_dataset_location
  default_table_expiration_ms = var.bigquery_table_partition_expiration_ms

  labels = {
    environment = var.environment
    function    = local.app_name
  }

  access {
    role          = "roles/bigquery.dataEditor"
    user_by_email = module.service_account.email
  }

  access {
    role          = "roles/bigquery.dataOwner"
    user_by_email = module.service_account.email
  }

  access {
    role   = "READER"
    domain = "moove.ai"
  }

  access {
    role          = "OWNER"
    user_by_email = "atlantis@moove-systems.iam.gserviceaccount.com"
  }

  access {
    role          = "OWNER"
    user_by_email = "alexm@moove.ai"
  }

  access {
    role          = "WRITER"
    user_by_email = module.service_account.email
  }

}

resource "google_bigquery_table" "table" {
  depends_on = [google_bigquery_dataset.dataset]
  project    = google_bigquery_dataset.dataset.project

  dataset_id               = google_bigquery_dataset.dataset.dataset_id
  table_id                 = var.bigquery_table_id
  require_partition_filter = true
  deletion_protection      = false

  time_partitioning {
    type  = "DAY"
    field = "timestamp_day"
  }

  labels = {
    environment = var.environment
    function    = local.app_name
  }

  schema = var.bigquery_table_schema
}


resource "google_bigquery_table_iam_member" "member" {
  project    = google_bigquery_table.table.project
  dataset_id = google_bigquery_table.table.dataset_id
  table_id   = google_bigquery_table.table.table_id
  role       = "roles/bigquery.dataOwner"
  member     = "serviceAccount:${module.service_account.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${module.service_account.email}"
}

resource "google_project_iam_member" "bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${module.service_account.email}"
}

resource "google_service_account_iam_member" "workload-identity" {
  depends_on = [module.service_account]

  member             = "serviceAccount:${local.k8s_cluster_project}.svc.id.goog[${local.k8s_namespace}/${var.k8s_service_account_name}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = module.service_account.name
}
