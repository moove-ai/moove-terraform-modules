locals {
  service_account_project_id   = var.service_account_project_id != "" ? var.service_account_project_id : var.project_id
  service_account_display_name = var.service_account_display_name != "" ? var.service_account_display_name : var.service_account_id
  service_account_description  = var.service_account_description != "" ? var.service_account_description : var.service_account_display_name
  pubsub_topic_name            = var.pubsub_topic_name != "" ? var.pubsub_topic_name : "${var.application_name}-${var.environment}"
  pubsub_subscription_name     = var.pubsub_subscription_name != "" ? var.pubsub_subscription_name : "${var.application_name}-${var.environment}"
}

data "google_project" "build-project" {
  project_id = var.build_project
}

data "google_project" "project" {
  project_id = var.project_id
}

data "google_service_account" "runner" {
  count      = var.create_service_account ? 0 : 1
  project    = local.service_account_project_id
  account_id = var.service_account_id
}


resource "google_project_iam_member" "artifact_registry_reader" {
  project = "moove-build"
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "cloud-run-reader" {
  bucket = "artifacts.${data.google_project.build-project.project_id}.appspot.com"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_service_account" "runner" {
  count        = var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = var.service_account_description
}

resource "google_service_account_iam_member" "deployer-act-as" {
  service_account_id = var.create_service_account ? google_service_account.runner[0].name : data.google_service_account.runner[0].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:deployer@moove-build.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "service-network-user" {
  project = var.network_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "runner-network-user" {
  project = var.network_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${var.create_service_account ? google_service_account.runner[0].email : data.google_service_account.runner[0].email}"
}

resource "google_project_iam_member" "service-vpc-user" {
  project = var.network_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "runner-vpc-user" {
  project = var.network_project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:${var.create_service_account ? google_service_account.runner[0].email : data.google_service_account.runner[0].email}"
}

resource "google_pubsub_topic" "topic" {
  count                      = var.pubsub_enabled ? 1 : 0
  project                    = var.project_id
  name                       = local.pubsub_topic_name
  message_retention_duration = var.pubsub_topic_message_retention_duration
  labels = {
    environment = var.environment
    function    = var.application_name
  }
}

resource "google_pubsub_subscription" "subscription" {
  count = var.pubsub_enabled ? 1 : 0
  name  = local.pubsub_subscription_name
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
  member       = "serviceAccount:${var.create_service_account ? google_service_account.runner[0].email : data.google_service_account.runner[0].email}"
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  count        = var.pubsub_enabled ? 1 : 0
  subscription = google_pubsub_subscription.subscription[0].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.create_service_account ? google_service_account.runner[0].email : data.google_service_account.runner[0].email}"
}
