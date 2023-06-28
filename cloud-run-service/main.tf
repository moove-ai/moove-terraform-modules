resource "google_cloud_run_v2_service" "service" {
  provider     = google-beta
  name         = var.service_name
  project      = var.project_id
  location     = var.service_location
  launch_stage = var.launch_stage
  ingress      = var.ingress

  template {
    labels = merge({
      service     = var.service_name,
      environment = var.environment,
      region      = var.service_location,
    }, var.labels)


    dynamic "containers" {
      for_each = var.containers
      content {
        name  = containers.value.name
        image = containers.value.image

        ports {
          container_port = containers.value.port
        }

        depends_on = containers.value.depends_on

        dynamic "volume_mounts" {
          for_each = containers.value.volume_mounts
          content {
            name       = volume_mounts.value.name
            mount_path = volume_mounts.value.mount_path
          }
        }
      }
    }

    dynamic "volumes" {
      for_each = var.volumes
      content {
        name = volumes.value.name
        empty_dir {
          medium     = volumes.value.medium
          size_limit = volumes.value.size_limit
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      launch_stage,
    ]
  }
}
