resource "google_monitoring_monitored_project" "project" {
  provider      = google-beta
  for_each      = toset(var.monitored_projects)
  metrics_scope = var.metrics_scope
  name          = each.key
}
