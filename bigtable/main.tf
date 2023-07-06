/**
 * # GCS Storage Modules
 *
 * Creates resources around any internal app which should be triggered on the creation of a GCS object
 *
 *
 * Written by Ben Hoskins for moove.ai
 */

resource "google_bigtable_instance" "production-instance" {
  name = var.instance_name
  project = var.project_id
  deletion_protection = var.deletion_protection

  cluster {
    cluster_id   = var.cluster_id
    storage_type = var.storage_type
    autoscaling_config {
      min_nodes = var.min_nodes
      max_nodes = var.max_nodes
      cpu_target = var.cpu_target
      storage_target = var.storage_target
    }
  }
}