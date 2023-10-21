resource "google_logging_metric" "log_metrics" {
  for_each = var.log_metrics

  name        = each.value.metric_name
  description = each.value.metric_description

  filter = <<EOT
    resource.type="global"
    logName="projects/${project_id}/logs/metrics-logger"
    jsonPayload.metric_name="${each.value.metric_name}"
  EOT

  metric_descriptor {
    metric_kind = each.value.metric_kind
    value_type  = each.value.value_type
    labels {
      key         = "app_name"
      description = "Name of the application"
      value_type  = "STRING"
    }
    labels {
      key         = "instance_id"
      description = "Instance ID of the app"
      value_type  = "STRING"
    }
  }

  label_extractors = {
    "app_name"    = "EXTRACT(jsonPayload.labels.app_name)"
    "instance_id" = "EXTRACT(jsonPayload.labels.instance_id)"
  }
}
