locals {
  test_build_name = var.test_build_name != "" ? var.test_build_name : "test-${var.github_repo}-dags"
}

data "google_service_account" "deployer" {
  account_id = var.deployer_account_id
  project = var.deployer_project_id
}

data "google_composer_environment" "staging_clusters" {
  for_each = { for idx, cluster in var.staging_clusters : idx => cluster }

  project = each.value.project_id
  name    = each.value.cluster_name
  region  = each.value.cluster_region
}

data "google_composer_environment" "production_clusters" {
  for_each = { for idx, cluster in var.production_clusters : idx => cluster }

  project = each.value.project_id
  name    = each.value.cluster_name
  region  = each.value.cluster_region
}

resource "google_storage_bucket_iam_member" "staging" {
  for_each = { for idx, cluster in var.staging_clusters : idx => cluster }

  bucket = data.google_composer_environment.staging_clusters[each.key].config[0].dag_gcs_prefix
  member = google_service_account.deployer.member
  role = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "production" {
  for_each = { for idx, cluster in var.production_clusters : idx => cluster }

  bucket = data.google_composer_environment.staging_clusters[each.key].config[0].dag_gcs_prefix
  member = google_service_account.deployer.member
  role = "roles/storage.objectAdmin"
}

resource "google_cloudbuild_trigger" "test_trigger" {
  project = var.build_project_id
  name = local.test_build_name
  location = "global"

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
    }
  }

  build {
    step {
      name = "python:3.8-slim"
      entrypoint = "pip"
      args = ["install", "-r", "requirements-test.txt", "--user"]
    }

    step {
      name = "python:3.8-slim"
      entrypoint = "python3.8"
      args = ["-m", "pytest", "-s", "dags/"]
    }
  }
}

resource "google_cloudbuild_trigger" "stage_trigger" {
  for_each = { for idx, cluster in var.staging_clusters : idx => cluster }

  project = each.value.project_id
  name    = "stage-${var.github_repo}-dags-${each.value.cluster_name}"
  location = "global"

  substitutions = {
    _DAGS_DIRECTORY = "dags/"
    _DAGS_BUCKET    = data.google_composer_environment.staging_clusters[each.key].config[0].dag_gcs_prefix
  }

  github {
    owner = var.github_owner
    name  = var.github_repo

    pull_request {
      branch = var.stage_build_branch_pattern
    }
  }

  build {
    step {
      name       = "python"
      entrypoint = "python"
      args       = ["utils/add_dags_to_composer.py", "--dags_directory=${_DAGS_DIRECTORY}", "--dags_bucket=${_DAGS_BUCKET}"]
    }
  }
}


resource "google_cloudbuild_trigger" "deploy_trigger" {
  for_each = { for idx, cluster in var.production_clusters : idx => cluster }

  project = each.value.project_id
  name    = "deploy-${var.github_repo}-dags-${each.value.cluster_name}"
  location = "global"

  substitutions = {
    _DAGS_DIRECTORY = "dags/"
    _DAGS_BUCKET    = data.google_composer_environment.staging_clusters[each.key].config[0].dag_gcs_prefix
  }

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "main"
    }
  }

  build {
    step {
      name       = "python"
      entrypoint = "python"
      args       = ["utils/add_dags_to_composer.py", "--dags_directory=${_DAGS_DIRECTORY}", "--dags_bucket=${_DAGS_BUCKET}"]
    }
  }
}
