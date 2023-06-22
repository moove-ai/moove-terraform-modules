resource "google_service_account" "k8s-thanos" {
  account_id = "k8s-thanos"
  project    = var.project_id
}
