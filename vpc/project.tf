module "host-project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1"
  random_project_id              = true
  name                           = var.host_project_name
  org_id                         = var.organization_id
  folder_id                      = var.folder_id
  billing_account                = var.billing_account
  enable_shared_vpc_host_project = true
  default_network_tier           = var.default_network_tier

  activate_apis = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}