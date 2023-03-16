resource "google_secret_manager_secret" "grafana-github_client_secret" {
  project   = "moove-systems"
  secret_id = "grafana-github_client_secret"

  labels = {
    environment = "mgmt"
    function    = "monitoring"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_storage_bucket_iam_member" "thanos-object-store-iam" {
  bucket = google_storage_bucket.thanos-prometheus-object-store.name
  member = "serviceAccount:${google_service_account.k8s-thanos.email}"
  role   = "roles/storage.objectAdmin"
}
