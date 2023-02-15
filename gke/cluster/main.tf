/**
 * # gke
 *
 * creates a GKE (beta-private-update-variant) cluster and deploys common helm resources to it
 *
 * 
 * Written by Alex Merenda for moove.ai
 */


locals {
  _cluster_name = replace(var.cluster_name, "-", "_")
}
data "google_service_account" "k8s-nodes" {

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
    user_by_email = data.google_service_account.k8s-nodes.email
  }

  access {
    role   = "READER"
    domain = "moove.ai"
  }

}
