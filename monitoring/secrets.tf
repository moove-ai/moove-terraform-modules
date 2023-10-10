resource "google_secret_manager_secret" "grafana-github_client_secret" {
  project   = var.secret_project_id
  secret_id = "grafana-github_client_secret"

  labels = {
    environment = "mgmt"
    function    = "monitoring"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    auto {
    }
  }
}

resource "google_storage_bucket_iam_member" "thanos-object-store-iam" {
  bucket = google_storage_bucket.thanos-prometheus-object-store.name
  member = "serviceAccount:${google_service_account.k8s-thanos.email}"
  role   = "roles/storage.objectAdmin"
}

resource "google_secret_manager_secret" "pagerduty-service-key" {
  project   = var.secret_project_id
  secret_id = "monitoring_pagerduty-service-key"

  labels = {
    function     = "monitoring"
    component    = "pagerduty"
    intergration = "google-cloud"
    environment  = var.environment
    terraformed  = "true"
  }

  replication {
    auto {
    }
  }
}
