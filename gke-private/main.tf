# google_client_config and kubernetes provider must be explicitly specified like the following.

data "google_client_config" "default" {}


module "gke" {
  source                           = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster-update-variant"
  version                          = "23.0.0"
  project_id                       = var.project_id
  name                             = var.cluster_name
  region                           = var.region
  zones                            = var.cluster_zones
  subnetwork                       = var.cluster_subnetwork
  network                          = var.cluster_network
  network_project_id               = var.cluster_network_project_id
  ip_range_pods                    = var.ip_range_pods
  ip_range_services                = var.ip_range_services
  gce_pd_csi_driver                = var.gce_pd_csi_driver
  http_load_balancing              = var.http_load_balancing
  network_policy                   = var.network_policy
  horizontal_pod_autoscaling       = var.horizontal_pod_autoscaling
  filestore_csi_driver             = var.filestore_csi_driver
  enable_private_endpoint          = var.enable_private_endpoint
  enable_private_nodes             = var.enable_private_nodes
  master_ipv4_cidr_block           = var.master_ipv4_cidr_block
  remove_default_node_pool         = var.remove_default_node_pool
  enable_network_egress_export     = "true"
  resource_usage_export_dataset_id = google_bigquery_dataset.resource-monitor.dataset_id
  istio                            = var.istio
  cloudrun                         = var.cloudrun
  dns_cache                        = var.dns_cache
  node_pools                       = var.node_pools
  node_pools_labels                = var.node_pools_labels
  node_pools_oauth_scopes          = var.node_pools_oauth_scopes
  node_pools_taints                = var.node_pools_taints
  node_pools_tags                  = var.node_pools_tags
  node_pools_metadata              = var.node_pools_metadata
  cluster_resource_labels          = var.cluster_labels
  master_authorized_networks       = var.master_authorized_networks
  service_account                  = google_service_account.k8s-nodes.email
  create_service_account           = false
}

module "k8s-common" {
  source                         = "../k8s-common"
  environment                    = var.environment
  project_id                     = var.project_id
  cluster_name                   = var.cluster_name
  region                         = var.region
  cluster_network                = var.cluster_network
  cluster_network_project_id     = var.cluster_network_project_id
  proxy_dns_name                 = "${var.proxy_dns}.moove.co.in"
  install_argocd                 = var.install_argocd
  install_common_resources       = var.install_common_resources
  install_cert_manager           = var.install_cert_manager
  install_cert_manager_pilot     = var.install_cert_manager_pilot
  install_external_dns           = var.install_external_dns
  install_external_secrets       = var.install_external_secrets
  install_external_secrets_pilot = var.install_external_secrets_pilot
  install_keda                   = var.install_keda
}
