locals {
  network_project_id = "moove-network-${var.environment}"
}

data "google_project" "build-project" {
  project_id = var.build_project
}

data "google_project" "project" {
  project_id = var.project_id
}

data "google_service_account" "deployer" {
  project    = var.build_project
  account_id = var.build_sa_name
}

resource "google_service_account" "runner" {
  account_id   = var.service_account_id != "" ? var.service_account_id : var.application_name
  project      = var.project_id
  display_name = var.service_account_display_name
  description  = var.service_account_description
}


resource "google_service_account_iam_member" "deployer-act-as" {
  service_account_id = google_service_account.runner.name
  role               = "roles/iam.serviceAccountUser"
  member             = data.google_service_account.deployer.member
}

resource "google_pubsub_topic" "topic" {
  count = var.pubsub_enabled ? 1 : 0

  project                    = var.project_id
  name                       = var.pubsub_topic_name != "" ? var.pubsub_topic_name : var.application_name
  message_retention_duration = var.pubsub_topic_message_retention_duration

  labels = {
    environment = var.environment
    function    = var.application_name
  }
}

resource "google_pubsub_subscription" "subscription" {
  count = var.pubsub_enabled ? 1 : 0

  name  = var.pubsub_subscription_name != "" ? var.pubsub_subscription_name : "${var.application_name}-subscription"
  topic = google_pubsub_topic.topic[0].name

  labels = {
    environment = var.environment
    function    = var.application_name
  }

  message_retention_duration = var.pubsub_subscription_message_retention_duration
  retain_acked_messages      = var.pubsub_retain_acked_messages

  ack_deadline_seconds = var.pubsub_ack_deadline_seconds

  dynamic "expiration_policy" {
    for_each = var.pubsub_expiration_policy != null ? [var.pubsub_expiration_policy] : []
    content {
      ttl = expiration_policy.value["ttl"]
    }
  }

  dynamic "retry_policy" {
    for_each = var.pubsub_retry_policy != null ? [var.pubsub_retry_policy] : []
    content {
      minimum_backoff = retry_policy.value["minimum_backoff"]
    }
  }

  enable_message_ordering = var.pubsub_enable_message_ordering
}

resource "google_pubsub_subscription_iam_member" "publisher" {
  count        = var.pubsub_enabled ? 1 : 0
  subscription = google_pubsub_subscription.subscription[0].name
  role         = "roles/pubsub.publisher"
  member       = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  count = var.pubsub_enabled ? 1 : 0

  subscription = google_pubsub_subscription.subscription[0].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_project_iam_member" "service-network-user" {
  count = var.vpc_connector != "" ? 1 : 0

  project = var.project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "runner-network-user" {
  count = var.vpc_connector != "" ? 1 : 0

  project = local.network_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_project_iam_member" "service-vpc-user" {
  count = var.vpc_connector != "" ? 1 : 0

  project = local.network_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "runner-vpc-user" {
  count = var.vpc_connector != "" ? 1 : 0

  project = local.network_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_artifact_registry_repository_iam_member" "cloud_run_artifact_registry_reader" {
  project    = var.build_project
  location   = "us"
  repository = "docker-us"
  role       = "roles/artifactregistry.reader"
  member     = google_service_account.runner.member
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  count = var.gke_project_id != "" ? 1 : 0

  service_account_id = google_service_account.runner.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.gke_project_id}.svc.id.goog[${var.environment}/contextualization-api]"
  ]
}