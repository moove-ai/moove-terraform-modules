module "proxy-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.cluster_network_project_id
  network                 = var.cluster_network
  internal_ranges_enabled = false
  internal_ranges         = []
  internal_target_tags    = []
  http_target_tags        = []
  https_target_tags       = []
  http_source_ranges      = []
  https_source_ranges     = []
  ssh_target_tags         = []
  ssh_source_ranges       = []
  custom_rules = {
    ingress-allow-http-proxy = {
      description = "Allows access to the GKE proxy to access private clusters"
      direction   = "INGRESS"
      action      = "allow"
      ranges = [
        "0.0.0.0/0"
      ]
      sources              = []
      targets              = ["gke-proxy"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports = [
            "8888",
            "22"
          ]
        }
      ]
      extra_attributes = {}
    }
  }
}
