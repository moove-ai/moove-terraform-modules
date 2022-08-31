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
  for_each = var.regions
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
