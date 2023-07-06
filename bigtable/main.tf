/**
 * # GCS Storage Modules
 *
 * Creates resources around any internal app which should be triggered on the creation of a GCS object
 *
 *
 * Written by Ben Hoskins for moove.ai
 */

resource "google_bigtable_instance" "instance" {
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

resource "google_bigtable_table" "table" {
  name = var.table_name
  project = var.project_id
  instance_name = var.instance_name
  deletion_protection = var.deletion_protection
}

resource "google_bigtable_gc_policy" "policy" {
  instance_name = google_bigtable_instance.instance.name
  table         = google_bigtable_table.table.name
  column_family = var.column_family
  gc_rules = var.gc_rules
}

