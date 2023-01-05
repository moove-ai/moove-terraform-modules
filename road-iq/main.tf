locals {
    k8s_sa = var.k8s_sa != "" ? var.k8s_sa : "road-iq"
    namespace = var.namespace != "" ? var.namespace : var.environment
    cluster_project_id = var.cluster_project_id != "" ? var.cluster_project_id : var.project_id
}


resource "google_service_account" "service-account" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Road IQ (K8s)"
  description  = "Used for the road-iq application. Coresponding K8s sa: ${local.k8s_sa} in namespace: ${local.namespace}"
}


resource "google_service_account_iam_member" "workload-identity" {
  member             = "serviceAccount:${local.cluster_project_id}.svc.id.goog[${local.namespace}/${local.k8s_sa}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.service-account.name
}


#module "road-iq-firewall-rules" {
#  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
#  project_id              = var.network_project_id
#  network                 = "${var.environment}-vpc"
#  internal_ranges_enabled = false
#  internal_ranges         = ["10.0.0.0/8"]
#  internal_target_tags    = ["private"]
#  http_target_tags        = []
#  https_target_tags       = []
#  http_source_ranges      = []
#  https_source_ranges     = []
#  ssh_target_tags         = []
#  ssh_source_ranges       = []
#  custom_rules = {
#    ingress-gke-clickhouse = {
#      description = "Allows access to the GKE master."
#      direction   = "INGRESS"
#      action      = "allow"
#      ranges = [
#        "10.0.0.0/8",
#      ]
#      sources              = []
#      targets              = ["gke", "clickhouse"]
#      use_service_accounts = false
#      rules = [
#        {
#          protocol = "tcp"
#          ports = [
#            "9000",
#          ]
#        }
#      ]
#      extra_attributes = {}
#    }
#  }
#}
#