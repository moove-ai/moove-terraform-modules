data "google_project" "build-project" {
  project_id = var.build_project
}

data "google_project" "project" {
  for_each   = var.environments
  project_id = each.value.project_id
}

resource "google_project_iam_member" "artifact_registry_reader" {
  for_each = var.environments
  project  = "moove-build"
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:service-${data.google_project.project[each.key].number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "cloud-run-reader" {
  for_each = var.environments
  bucket   = "artifacts.${data.google_project.build-project.project_id}.appspot.com"
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:service-${data.google_project.project[each.key].number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_service_account" "runner" {
  for_each     = var.environments
  account_id   = var.service_account_id != "" ? var.service_account_id : var.application_name
  project      = each.value.project_id
  display_name = var.service_account_display_name
  description  = var.service_account_description
}


resource "google_service_account_iam_member" "deployer-act-as" {
  for_each           = var.environments
  service_account_id = google_service_account.runner[each.key].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:deployer@moove-build.iam.gserviceaccount.com"
}

resource "google_pubsub_topic" "topic" {
  for_each                   = var.pubsub_enabled ? var.environments : {}
  project                    = each.value.project_id
  name                       = var.pubsub_topic_name != "" ? var.pubsub_topic_name : var.application_name
  message_retention_duration = var.pubsub_topic_message_retention_duration

  labels = {
    environment = each.key
    function    = var.application_name
  }
}

resource "google_pubsub_subscription" "subscription" {
  for_each = var.pubsub_enabled ? var.environments : {}
  name     = var.pubsub_subscription_name != "" ? var.pubsub_subscription_name : "${var.application_name}-subscription"
  topic    = google_pubsub_topic.topic[each.key].name

  labels = {
    environment = each.key
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
  for_each     = var.pubsub_enabled ? var.environments : {}
  subscription = google_pubsub_subscription.subscription[each.key].name
  role         = "roles/pubsub.publisher"
  member       = "serviceAccount:${google_service_account.runner[each.key].email}"
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  for_each     = var.pubsub_enabled ? var.environments : {}
  subscription = google_pubsub_subscription.subscription[each.key].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.runner[each.key].email}"
}

resource "google_project_iam_member" "service-network-user" {
  for_each = var.environments
  project  = each.value.network_project_id
  role     = "roles/compute.networkUser"
  member   = "serviceAccount:service-${data.google_project.project[each.key].number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "runner-network-user" {
  for_each = var.environments
  project  = each.value.network_project_id
  role     = "roles/compute.networkUser"
  member   = "serviceAccount:${google_service_account.runner[each.key].email}"
}

resource "google_project_iam_member" "service-vpc-user" {
  for_each = var.environments
  project  = each.value.network_project_id
  role     = "roles/vpcaccess.user"
  member   = "serviceAccount:service-${data.google_project.project[each.key].number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "runner-vpc-user" {
  for_each = var.environments
  project  = each.value.network_project_id
  role     = "roles/vpcaccess.user"
  member   = "serviceAccount:${google_service_account.runner[each.key].email}"
}
