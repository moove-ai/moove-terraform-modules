output "cluster_name" {
  value = "${var.environment}-${var.region}"
}

output "resource_monitor" {
  value = var.create_resource_monitor ? google_bigquery_dataset.resource-monitor[0].dataset_id : null
}
