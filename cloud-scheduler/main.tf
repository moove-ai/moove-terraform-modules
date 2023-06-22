
resource "google_cloud_scheduler_job" "job" {
  name             = var.job_name
  description      = var.job_description
  schedule         = var.job_schedule
  time_zone        = var.job_timezone
  attempt_deadline = var.job_deadline

  retry_config {
    retry_count = var.job_retry_count
  }

  http_target {
    http_method = var.http_method
    uri         = var.http_uri
  }

  oauth_token {
    service_account_email = data.google_compute_default_service_account.default.email
  }
}
