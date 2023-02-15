locals {
  proxy_dns = var.proxy_dns != "" ? var.proxy_dns : "${var.environment}-${var.region}.gke"
}


data "google_compute_subnetwork" "private-subnetwork" {
  project = var.cluster_network_project_id
  name    = var.cluster_subnetwork
  region  = var.region
}


resource "google_compute_instance" "gke-proxy" {
  project                   = var.project_id
  machine_type              = "e2-micro"
  name                      = "gke-proxy-${var.region}"
  tags                      = ["public", "gke-proxy", "private", var.environment]
  zone                      = var.proxy_zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata.ssh-keys
    ]
  }

  metadata_startup_script = <<EOT
      apt -y install tinyproxy
      grep 'Allow localhost' /etc/tinyproxy/tinyproxy.conf
      if [ $? -ne 0 ]; then echo "Allow localhost" >> /etc/tinyproxy/tinyproxy.conf; fi
      grep 'Allow 0.0.0.0/0' /etc/tinyproxy/tinyproxy.conf
      if [ $? -ne 0 ]; then echo "Allow 0.0.0.0/0" >> /etc/tinyproxy/tinyproxy.conf; fi
      systemctl restart tinyproxy
      EOT

  network_interface {
    subnetwork = data.google_compute_subnetwork.private-subnetwork.self_link
  }
}

data "google_dns_managed_zone" "moove-internal" {
  name    = "moove-internal"
  project = "moove-systems"
}

resource "google_dns_record_set" "proxy" {
  name         = "${local.proxy_dns}.${data.google_dns_managed_zone.moove-internal.dns_name}"
  project      = data.google_dns_managed_zone.moove-internal.project
  managed_zone = data.google_dns_managed_zone.moove-internal.name
  type         = "A"
  rrdatas      = [google_compute_instance.gke-proxy.network_interface.0.network_ip]
}
