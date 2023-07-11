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
  dynamic "cluster" {
    for_each = [for cluster in var.clusters : {
      cluster_id = cluster.cluster_id
      zone = lookup(cluster, "zone", null)
      storage_type = lookup(cluster, "zone", "SSD")
      autoscaling_config = {min_nodes = cluster.autoscaling_config.min_nodes,
                            max_nodes = cluster.autoscaling_config.max_nodes,
                            cpu_target = cluster.autoscaling_config.cpu_target,
                            storage_target = cluster.autoscaling_config.storage_target
      }
    }]
  }
# Ex. Cluster
#  cluster {
#    cluster_id   = var.cluster_id
#    storage_type = var.storage_type
#    autoscaling_config {
#      min_nodes = var.min_nodes
#      max_nodes = var.max_nodes
#      cpu_target = var.cpu_target
#      storage_target = var.storage_target
#    }
#  }
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

resource "google_bigtable_app_profile" "profile" {
  app_profile_id = var.app_profile_id
  description = var.app_profile_description
  multi_cluster_routing_use_any = var.multi_cluster_routing_use_any
  single_cluster_routing {
    cluster_id   = var.cluster_id
    allow_transactional_writes = var.allow_transactional_writes
  }
  instance = var.instance_name
  project = var.project_id
}

