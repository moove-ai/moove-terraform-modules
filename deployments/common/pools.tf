locals {
  network_project = var.environment == "mgmt" ? "moove-systems" : "moove-network-${var.environment}"
  network = "${var.environment}-vpc"
}

data "google_compute_network" "network" {
  project = local.network_project
  name = local.network
}

resource "google_project_service" "servicenetworking" {
  project = local.network_project
  service = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_global_address" "worker_range" {
  name          = "common-worker-pool"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 28
  network       = data.google_compute_network.network.id
}

resource "google_service_networking_connection" "worker_pool_conn" {
  network                 = data.google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.worker_range.name]
  depends_on              = [google_project_service.servicenetworking]
}

resource "google_cloudbuild_worker_pool" "pool" {
  for_each = toset(var.regions)
  name = "${each.key}-common-worker-pool"
  location = each.key
  worker_config {
    disk_size_gb = 100
    machine_type = var.machine_type
    no_external_ip = true
  }
  network_config {
    peered_network = google_compute_network.network.id
  }
  depends_on = [google_service_networking_connection.worker_pool_conn]
}
