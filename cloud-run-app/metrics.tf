locals {
  monitoring_project_id = "moove-monitor-${var.environment}"
}

resource "google_pubsub_topic" "cross_project_logs_topic" {
  project = local.monitoring_project_id
  name    = "${var.service_name}-logs"
}

resource "google_pubsub_topic_iam_binding" "topic_publisher_binding" {
  depends_on = [google_pubsub_topic.cross_project_logs_topic]

  project = "moove-monitor-staging"
  topic   = google_pubsub_topic.cross_project_logs_topic.name
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:cloud-logs@system.gserviceaccount.com"
  ]
}

resource "google_logging_project_sink" "cross_project_sink" {
  depends_on = [google_pubsub_topic.cross_project_logs_topic]

  project                = var.project_id
  name                   = "${var.service_name}-logs-sink"
  destination            = "pubsub.googleapis.com/projects/${local.monitoring_project_id}/topics/${google_pubsub_topic.cross_project_logs_topic.name}"
  unique_writer_identity = true

  filter = <<-EOT
    resource.type="cloud_run_revision" AND
    resource.labels.service_name="${var.service_name}" AND
    jsonPayload.metric_name =~"contextualization*"
  EOT
}

resource "google_logging_metric" "log_metrics" {
  for_each   = var.log_metrics
  depends_on = [google_logging_project_sink.cross_project_sink]

  project     = var.monitoring_project_id
  name        = each.value.metric_name
  description = each.value.metric_description

  filter = <<EOT
    resource.type = "cloud_run_revision"
    resource.labels.service_name = "${var.service_name}"
    jsonPayload.metric_name = "${each.value.metric_name}"
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