data "google_compute_network" "network" {
  project = "moove-systems"
  name = "mgmt-vpc"
}

resource "google_project_service" "network" {
  project = "moove-systems"
  service = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "project" {
  project = "moove-builds-a747"
  service = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_global_address" "worker_range" {
  name          = "k8s-worker-pool"
  project = "moove-systems"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = data.google_compute_network.network.id
}

resource "google_service_networking_connection" "worker_pool_conn" {
  network                 = data.google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.worker_range.name]
  depends_on              = [
    google_project_service.network,
    google_project_service.project,
    ]
}

resource "google_cloudbuild_worker_pool" "pool" {
  project = "moove-builds-a747"
  name = "k8s-worker-pool"
  location = "us-central1"
  worker_config {
    disk_size_gb = 100
    machine_type = "e2-standard-2"
    no_external_ip = true
  }
  network_config {
    peered_network = data.google_compute_network.network.id
  }
}
