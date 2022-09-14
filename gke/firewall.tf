module "agrocd-ingress" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.cluster_network_project_id
  network                 = var.cluster_network
  internal_ranges_enabled = false
  internal_ranges         = ["10.0.0.0/8"]
  internal_target_tags    = ["private"]
  http_target_tags        = []
  https_target_tags       = []
  http_source_ranges      = []
  https_source_ranges     = []
  ssh_target_tags         = []
  ssh_source_ranges       = []
  custom_rules = {
    ingress-allow-http-https-argocd = {
      description          = "Allows http and https ingress to GKE nodes"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = [
                              "10.80.0.0/16"
                              ]
      sources              = []
      targets              = ["private", "gke"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports    = [
            "80",
            "443"
            ]
        }
      ]
      extra_attributes = {}
    }
  }
}
