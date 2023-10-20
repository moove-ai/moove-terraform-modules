
resource "google_monitoring_notification_channel" "pagerduty-channel" {
  project      = "moove-monitor-${var.environment}"
  display_name = "PagerDuty for Google Cloud Monitoring"
  type         = "pagerduty"
  labels = {
    "service_key" = data.google_secret_manager_secret_version.pagerduty_gcp_key.secret_data
  }
}

resource "google_monitoring_notification_channel" "slack-channel" {
  project      = "moove-monitor-${var.environment}"
  display_name = "slack for Google Cloud Monitoring"
  type         = "slack"
  labels = {
    "service_key" = data.google_secret_manager_secret_version.pagerduty_gcp_key.secret_data
  }
}
