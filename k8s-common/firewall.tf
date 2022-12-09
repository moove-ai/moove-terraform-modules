module "gke-firewall-rules" {
  count                   = var.create_firewall_rules ? 1 : 0
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
    ingress-gke-master = { # needed for Keda
      description = "Allows access to the GKE master."
      direction   = "INGRESS"
      action      = "allow"
      ranges = [
        "10.11.112.16/28",
        "10.40.113.16/28",
        "10.80.112.16/28",
        "10.130.112.0/28",
      ]
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
    ingress-gke-internal = { 
      description = "Allows access to gke internally."
      direction   = "INGRESS"
      action      = "allow"
      ranges = [
        "10.0.0.0/8",
      ]
      sources              = ["gke"]
      targets              = ["gke"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports = [
            "443",
          ]
        }
      ]
      extra_attributes = {}
    }
    ingress-allow-http-https-argocd = {
      description = "Allows http and https ingress to GKE nodes"
      direction   = "INGRESS"
      action      = "allow"
      ranges = [
        "0.0.0.0/0"
      ]
      sources              = []
      targets              = ["private", "gke"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports = [
            "80",
            "443"
          ]
        }
      ]
      extra_attributes = {}
    }
    ingress-allow-prometheus = {
      description = "Allows access to prometheus"
      direction   = "INGRESS"
      action      = "allow"
      ranges = [
        "10.0.0.0/8"
      ]
      sources              = []
      targets              = ["private"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports = [
            "9090",
          ]
        }
      ]
      extra_attributes = {}
    }
    # Needed for metrics
    ingress-allow-thanos = {
      description = "Allows access to thanos"
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
            "10901",
          ]
        }
      ]
      extra_attributes = {}
    }
    # Redis
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
