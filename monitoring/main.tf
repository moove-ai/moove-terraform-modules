locals {
  object_store_config = <<-EOT
  type: GCS
  config:
    bucket: "${google_storage_bucket.thanos-prometheus-object-store.name}"
    service_account: |-
      ${indent(4, base64decode(google_service_account_key.k8s-thanos.private_key))}
  EOT
  data       = jsondecode(base64decode(google_service_account_key.bigquery-systems.private_key))
  key        = local.data.private_key
  datasource = <<-EOT
  apiVersion: 1
  datasources:
    - name: BigQuery-Systems
      uid: bq_systems
      type: grafana-bigquery-datasource
      access: proxy
      jsonData:
        tokenUri: https://oauth2.googleapis.com/token
        clientEmail: ${google_service_account.bigquery-systems.email}
        authenticationType: jwt
        defaultProject: moove-systems
      secureJsonData:
        privateKey: |
          ${indent(8, local.key)}
  EOT
}

resource "google_service_account" "k8s-grafana" {
  account_id   = "k8s-grafana"
  display_name = "Grfana"
  description  = "Service account used for the the persistent monitoring grafana application"
  project      = var.project_id
}

resource "google_service_account_iam_member" "workload-identity" {
  for_each           = toset(var.regions)
  member             = "serviceAccount:${var.cluster_project_id}.svc.id.goog[systems/monitoring-prometheus-mgmt-${each.key}-grafana]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.k8s-grafana.name
}

resource "google_project_iam_member" "k8s-grafana-iam-bq" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.k8s-grafana.email}"
}

resource "google_project_iam_member" "k8s-grafana-iam-monitoring" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.k8s-grafana.email}"
}

resource "google_service_account" "k8s-thanos" {
  account_id   = "k8s-thanos"
  display_name = "Monitoring"
  description  = "Service account used for the the persistent monitoring application"
  project      = var.project_id
}

resource "google_service_account_key" "k8s-thanos" {
  service_account_id = google_service_account.k8s-thanos.name
}

resource "google_storage_bucket" "thanos-prometheus-object-store" {
  project  = var.project_id
  location = "US"
  name     = "moove-metrics-storage"

  labels = {
    environment = "mgmt"
    app         = "monitoring"
    function    = "metric-store"
    client      = "moove"
    terraformed = "true"
    project     = var.project_id
  }
}

resource "google_secret_manager_secret" "thanos-object-store-config" {
  project   = "moove-secrets"
  secret_id = "thanos-object-store-config"

  labels = {
    environment = "mgmt"
    function    = "monitoring"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "thanos-object-store-config" {
  secret      = google_secret_manager_secret.thanos-object-store-config.id
  secret_data = local.object_store_config
}

resource "google_service_account" "bigquery-systems" {
  project = "moove-systems"
  account_id = "bigquery-systems"
  display_name = "BigQuery Systems Monitor"
  description = "Service account used to monitor BigQuery Billing exported to the `moove-systems` project"
}

resource "google_service_account_key" "bigquery-systems" {
  service_account_id = google_service_account.bigquery-systems.name
}

resource "google_project_iam_member" "bq-viewer" {
  project = "moove-systems"
  role    = "roles/bigquery.dataViewer"
  member  = google_service_account.bigquery-systems.member
}

resource "google_project_iam_member" "bq-user" {
  project = "moove-systems"
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.bigquery-systems.member
}


resource "google_secret_manager_secret" "bigquery-systems-service-account" {
  project   = "moove-secrets"
  secret_id = "systems_grafana-bigquery-billing-datasource"

  labels = {
    environment = "mgmt"
    function    = "monitoring"
    client      = "moove"
    terraformed = "true"
    secret-data = "terraform"
  }

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "bivquery-sa-key" {
  secret      = google_secret_manager_secret.bigquery-systems-service-account.id
  secret_data = local.datasource
}
