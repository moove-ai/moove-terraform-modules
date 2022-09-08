module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id      = var.project_id
  network_name    = var.network_name
  shared_vpc_host = var.shared_vpc_host
  routing_mode    = var.routing_mode

  subnets = var.vpc_subnets
  secondary_ranges = var.secondary_ranges
  routes = var.routes 
}

module "router" {
  for_each = toset(var.regions)
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"
  project = var.project_id
  name    = "${var.environment}-${each.key}"
  network = module.vpc.network_name
  region  = each.key

  nats = [{
    name = "${var.environment}-${each.key}-nat"
  }]
}

module "default-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project_id
  network                 = module.vpc.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.0.0.0/8"]
  internal_target_tags    = ["private"]
  http_target_tags        = []
  https_target_tags       = []
  http_source_ranges      = []
  https_source_ranges     = []
  ssh_target_tags         = []
  ssh_source_ranges       = []
  custom_rules = {
    ingress-allow-private-ssh = {
      description          = "Allows SSH ingress to hosts with the private tag"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = [
                              "10.0.64.0/20",
                              "10.80.0.0/20",
                              "10.0.0.0/20",
                              "10.10.0.0/20",
                              "10.80.160.0/24"
                              ]
      sources              = []
      targets              = ["private"]
      use_service_accounts = false
      rules = [
        {
          protocol = "tcp"
          ports    = [
            "22"
            ]
        }
      ]
      extra_attributes = {}
    }
    ingress-allow-private-icmp = {
      description          = "Allows SSH ingress to hosts with the private tag"
      direction            = "INGRESS"
      action               = "allow"
      ranges               = ["0.0.0.0/0"]
      sources              = []
      targets              = ["private"]
      use_service_accounts = false
      rules = [
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      extra_attributes = {}
    }
  }
}
