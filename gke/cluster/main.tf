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
  account_id = "k8s-nodes"
  project    = var.project_id
}
