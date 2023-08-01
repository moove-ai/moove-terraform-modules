resource "google_compute_instance" "clickhouse" {
  count        = var.instance_count
  name         = "clickhouse-${count.index}"
  machine_type = var.machine_type
  zone         = var.clickhouse_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network            = var.shared_vpc
    subnetwork         = var.subnetwork
    subnetwork_project = var.network_project_id
  }

  metadata_startup_script = file("database/install_clickhouse.sh")
}
