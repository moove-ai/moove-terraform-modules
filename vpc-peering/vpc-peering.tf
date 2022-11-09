resource "google_compute_network_peering" "local-to-remote" {
  name         = "${data.google_compute_network.local.name}-to-${data.google_compute_network.remote.name}"
  network      = data.google_compute_network.local.self_link
  peer_network = data.google_compute_network.remote.self_link
}

resource "google_compute_network_peering" "remote-to-local" {
  name         = "${data.google_compute_network.remote.name}-to-${data.google_compute_network.local.name}"
  network      = data.google_compute_network.remote.self_link
  peer_network = data.google_compute_network.local.self_link
}

data "google_compute_network" "local" {
  name                    = var.network_name
  project = var.network_project_id
}

data "google_compute_network" "remote" {
  name                    = var.remote_network_name
  project = var.remote_network_project_id
}