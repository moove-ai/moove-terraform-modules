resource "google_clouddeploy_target" "data-pipelines-staging" {
  provider         = google-beta
  project          = module.builds.project_id
  location         = var.deploy_region
  name             = "staging"
  description      = "Staging"
  require_approval = false

  execution_configs {
    usages            = ["RENDER", "DEPLOY", "VERIFY", "PREDEPLOY", "POSTDEPLOY"]
    execution_timeout = "3600s"
    service_account   = "deployer@moove-build.iam.gserviceaccount.com"
  }

  multi_target {
    target_ids = ["data-pipelines-staging-us-central1"]
  }
}

resource "google_clouddeploy_target" "data-pipelines-production" {
  provider         = google-beta
  project          = module.builds.project_id
  location         = var.deploy_region
  name             = "production"
  description      = "Production"
  require_approval = false

  execution_configs {
    usages            = ["RENDER", "DEPLOY", "VERIFY", "PREDEPLOY", "POSTDEPLOY"]
    execution_timeout = "3600s"
    service_account   = "deployer@moove-build.iam.gserviceaccount.com"
  }

  multi_target {
    target_ids = ["data-pipelines-production-us-central1"]
  }
}

resource "google_clouddeploy_target" "data-pipelines-production-us-central1" {
  provider         = google-beta
  project          = module.builds.project_id
  location         = var.deploy_region
  name             = "data-pipelines-production-us-central1"
  description      = "Data Pipelines Production (us-central1)"
  require_approval = false

  execution_configs {
    usages            = ["RENDER", "DEPLOY", "VERIFY", "PREDEPLOY", "POSTDEPLOY"]
    execution_timeout = "3600s"
    service_account   = "deployer@moove-build.iam.gserviceaccount.com"
  }

  run {
    location = "projects/moove-data-pipelines/locations/us-central1"
  }
}

resource "google_clouddeploy_target" "data-pipelines-production-us-west1" {
  provider         = google-beta
  project          = module.builds.project_id
  location         = var.deploy_region
  name             = "data-pipelines-production-us-west1"
  description      = "Data Pipelines Production (us-west1)"
  require_approval = false

  execution_configs {
    usages            = ["RENDER", "DEPLOY", "VERIFY", "PREDEPLOY", "POSTDEPLOY"]
    execution_timeout = "3600s"
    service_account   = "deployer@moove-build.iam.gserviceaccount.com"
  }

  run {
    location = "projects/moove-data-pipelines/locations/us-west1"
  }
}

resource "google_clouddeploy_target" "data-pipelines-staging-us-central1" {
  provider         = google-beta
  project          = module.builds.project_id
  location         = var.deploy_region
  name             = "data-pipelines-staging-us-central1"
  description      = "Data Pipelines Staging (us-central1)"
  require_approval = false

  execution_configs {
    usages            = ["RENDER", "DEPLOY", "VERIFY", "PREDEPLOY", "POSTDEPLOY"]
    execution_timeout = "3600s"
    service_account   = "deployer@moove-build.iam.gserviceaccount.com"
  }

  run {
    location = "projects/moove-data-pipelines-staging/locations/us-central1"
  }
}

resource "google_clouddeploy_target" "data-pipelines-staging-us-west1" {
  provider         = google-beta
  project          = module.builds.project_id
  location         = var.deploy_region
  name             = "data-pipelines-staging-us-west1"
  description      = "Data Pipelines Staging (us-west1)"
  require_approval = false

  execution_configs {
    usages            = ["RENDER", "DEPLOY", "VERIFY", "PREDEPLOY", "POSTDEPLOY"]
    execution_timeout = "3600s"
    service_account   = "deployer@moove-build.iam.gserviceaccount.com"
  }

  run {
    location = "projects/moove-data-pipelines-staging/locations/us-west1"
  }
}
