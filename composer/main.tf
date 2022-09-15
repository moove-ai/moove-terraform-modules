module "composer" {
  source  = "terraform-google-modules/composer/google"
  version = "~> 2.0"

  project_id                             = var.project_id
  region                                 = var.region
  composer_env_name                      = var.composer_env_name
  network_project_id                     = var.network_project_id
  network                                = var.network
  subnetwork                             = var.subnetwork
  master_ipv4_cidr                       = var.master_ipv4_cidr
  pod_ip_allocation_range_name           = var.pod_ip_allocation_range_name
  service_ip_allocation_range_name       = var.service_ip_allocation_range_name
  tags                                   = var.tags
  enable_private_endpoint                = var.private_endpoint
  use_private_environment                = var.use_private_environment
  environment_size                       = var.environment_size
  cloud_composer_network_ipv4_cidr_block = var.cloud_composer_network_ipv4_cidr_block
  composer_service_account               = var.composer_service_account
  labels                                 = var.labels
  worker                                 = var.worker_resources
}
