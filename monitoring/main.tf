#resource "google_service_account" "prometheus" {
#  project = var.project_id
#  account_id   = "k8s-prometheus"
#  display_name = "Prometheus (Kubernetes). Service account used for our monitoring stack"
#}
#
#resource "google_service_account_iam_member" "sa-workload-identity" {
#  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.k8s_sa_name}]"
#  role               = "roles/iam.workloadIdentityUser"
#  service_account_id = google_service_account.sa.name
#}
