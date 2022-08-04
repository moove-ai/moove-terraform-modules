resource "google_bigquery_dataset" "resource-monitor" {
    project = var.project_id
    dataset_id = var.resource_usage_export_dataset_id
    friendly_name = "Kubernetes Usage Export for ${var.cluster_name}"
    location = "US"
    labels = {
      "environment" = var.environment
      "cluster" = var.cluster_name
    }

    access {
      role = "OWNER"
      user_by_email = google_service_account.k8s-nodes.email
    }

    access {
      role   = "READER"
      domain = "moove.ai"
    }
  
}