locals {
  _cluster_name = replace(var.cluster_name, "-", "_")
}


resource "google_bigquery_dataset" "resource-monitor" {
  project       = var.project_id
  dataset_id    = "${local._cluster_name}_export"
  friendly_name = "Kubernetes Usage Export for ${var.cluster_name}"
  location      = "US"
  labels = {
    "environment" = var.environment
    "cluster"     = var.cluster_name
  }

  access {
    role          = "OWNER"
    user_by_email = google_service_account.k8s-nodes.email
  }

  access {
    role   = "READER"
    domain = "moove.ai"
  }

}