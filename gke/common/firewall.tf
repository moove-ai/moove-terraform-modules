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
    ingress-gke-master = {
      description          = "Allows access to the GKE master."
      direction            = "INGRESS"
      action               = "allow"
      ranges               = var.gke_master_ranges
      sources              = []
      targets              = ["gke"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports = [
            "6443",
          ]
        }
      ]
      extra_attributes = {}
    }
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
    ingress-redis = {
      description = "Allows access to redis."
      direction   = "INGRESS"
      action      = "allow"
      ranges = [
        "10.0.0.0/8"
      ]
      sources              = []
      targets              = ["gke"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports = [
            "6379",
          ]
        }
      ]
      extra_attributes = {}
    }
    ingress-gce-l7 = {
      description = "GCE L7 Firewall Rules"
      direction   = "INGRESS"
      action      = "allow"
      ranges = [
        "130.211.0.0/22",
        "35.191.0.0/16",
      ]
      sources              = []
      targets              = ["gke"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports = [
            "30000-32767",
            "8080",
          ]
        }
      ]
      extra_attributes = {}
    }
  }
}
