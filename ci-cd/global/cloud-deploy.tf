resource "google_clouddeploy_target" "staging" {
  project     = module.builds.project_id
  location    = var.deploy_region
  name        = "staging"
  description = "staging"

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account   = "deployer@moove-build.iam.gserviceaccount.com"
  }

  require_approval = false

  run {
    location = "projects/moove-data-pipelines-staging/locations/us-central1"
  }
  provider = google-beta
}

resource "google_clouddeploy_target" "production" {
  project     = module.builds.project_id
  location    = var.deploy_region
  name        = "production"
  description = "Production"

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account   = "deployer@moove-build.iam.gserviceaccount.com"
  }

  require_approval = false

  run {
    location = "projects/moove-data-pipelines/locations/us-central1"
  }
  provider = google-beta
}
