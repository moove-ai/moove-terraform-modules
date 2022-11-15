output "resource-monitor-dataset" {
  value = google_bigquery_dataset.resource-monitor.dataset_id
}

output "cluster_name" {
  value = "${var.environment}-${var.region}"
}

output "proxy_dns_name" {
  value = "${google_dns_record_set.proxy.name}.${data.google_dns_managed_zone.moove-internal.name}"
}