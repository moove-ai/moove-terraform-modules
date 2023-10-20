resource "google_secret_manager_secret" "pagerduty" {
    project = var.secret_project_id
    secret_id = "pagerduty-gcp-key"
    replication {
        auto {}
    }

    labels = {
      environment = var.environment
      function = "gcp-alerting"
      terraformed = "true"
      component = "pagerduty"
      manual-input = "true"
    }
}

resource "google_secret_manager_secret" "slack" {
    project = var.secret_project_id
    secret_id = "slack-gcp-key"
    replication {
        auto {}
    }

    labels = {
      environment = var.environment
      function = "gcp-alerting"
      terraformed = "true"
      component = "slack"
      manual-input = "true"
    }
}
