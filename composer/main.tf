/**
 * # Composer
 *
 * Creates composer resources
 *
 * [based on composer](https://registry.terraform.io/modules/terraform-google-modules/composer/google/latest/submodules/create_environment_v2)
 * 
 * Written by Alex Merenda for moove.ai
 */

module "composer" {
  source = "terraform-google-modules/composer/google//modules/create_environment_v2"
  #version = "~> 2.0"

  project_id         = var.project_id
  region             = var.region
  composer_env_name  = var.composer_env_name
  network_project_id = var.network_project_id
  network            = var.network
  subnetwork         = var.subnetwork
  #master_ipv4_cidr                       = var.master_ipv4_cidr
  pod_ip_allocation_range_name     = var.pod_ip_allocation_range_name
  service_ip_allocation_range_name = var.service_ip_allocation_range_name
  tags                             = var.tags
  enable_private_endpoint          = var.enable_private_endpoint
  use_private_environment          = var.use_private_environment
  environment_size                 = var.environment_size
  #cloud_composer_network_ipv4_cidr_block = var.cloud_composer_network_ipv4_cidr_block
  composer_service_account = var.create_service_account == false ? var.composer_service_account : resource.google_service_account.serviceaccount[0].email
  labels                   = var.labels
  worker                   = var.worker_resources
  image_version            = var.image_version
  pypi_packages            = var.pypi_packages
  depends_on = [
    google_service_account.serviceaccount,
    google_project_service.composer,
    google_project_iam_member.project,
    google_project_iam_member.worker,
  ]
}

resource "google_service_account" "serviceaccount" {
  count       = var.create_service_account ? 1 : 0
  project     = var.project_id
  account_id  = var.service_account_name == "" ? var.composer_env_name : var.service_account_name
  description = "Service Account used for ${var.composer_env_name}"
  depends_on = [
    google_project_service.composer,
  ]
}

resource "google_project_service" "composer" {
  project                    = var.project_id
  service                    = "composer.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false

  timeouts {
    create = "5m"
    update = "5m"
  }
}

data "google_project" "project" {
  project_id = var.project_id
}

data "google_service_account" "serviceaccount" {
  count      = var.create_service_account ? 0 : 1
  project    = var.project_id
  account_id = var.service_account_name
}

resource "google_project_iam_member" "project" {
  project = var.network_project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
  depends_on = [
    google_project_service.composer,
  ]
}

resource "google_project_iam_member" "worker" {
  project = var.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${var.create_service_account == false ? data.google_service_account.serviceaccount[0].email : google_service_account.serviceaccount[0].email}"
  depends_on = [
    google_project_service.composer,
    google_service_account.serviceaccount
  ]
}
