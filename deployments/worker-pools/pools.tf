locals {
  network = "${var.environment}-vpc"
}

data "google_compute_network" "network" {
  project = var.network_project
  name    = local.network
}

resource "google_project_service" "network" {
  project            = var.network_project
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "project" {
  project            = var.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_global_address" "worker_range" {
  name          = "common-worker-pool"
  project       = var.network_project
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = data.google_compute_network.network.id
}

resource "google_service_networking_connection" "worker_pool_conn" {
  network                 = data.google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.worker_range.name]
  depends_on = [
    google_project_service.network,
    google_project_service.project,
  ]
}

resource "google_cloudbuild_worker_pool" "pool" {
  project  = var.project_id
  for_each = toset(var.regions)
  name     = "${each.key}-common-worker-pool"
  location = each.key
  worker_config {
    disk_size_gb   = 100
    machine_type   = var.machine_type
    no_external_ip = false
  }
  network_config {
    peered_network = data.google_compute_network.network.id
  }
}
