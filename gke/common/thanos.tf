resource "google_service_account" "k8s-thanos" {
  project = var.project_id
  account_id = "k8s-thanos"
}

resource "google_service_account_key" "k8s-thanos" {
  service_account_id = google_service_account.k8s-thanos.name
}
