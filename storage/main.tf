/**
 * # GCS Storage Modules 
 *
 * Creates resources around any internal app which should be triggered on the creation of a GCS object
 *
 * 
 * Written by Alex Merenda for moove.ai
 */

locals {
  service_account_project_id = var.service_account_project_id != "" ? var.service_account_project_id : var.project_id
  bucket_project             = var.bucket_project != "" ? var.bucket_project : var.project_id
  storage_transfer_project   = var.storage_transfer_project != "" ? var.storage_transfer_project : var.project_id
}

# Application
resource "google_service_account" "service-account" {
  count        = var.create_service_account ? 1 : 0
  project      = local.service_account_project_id
  account_id   = var.service_account_id
  display_name = var.service_account_name
  description  = var.service_account_description
}

data "google_service_account" "service-account" {
  count      = var.create_service_account ? 0 : 1
  account_id = var.service_account_id
  project    = local.service_account_project_id
}

data "google_storage_project_service_account" "gcs_account" {
  project = local.bucket_project
}

resource "google_storage_bucket" "bucket" {
  count    = var.create_bucket ? 1 : 0
  name     = var.name
  project  = local.bucket_project
  location = var.location
  labels = merge({
    project     = local.bucket_project
    terraformed = "true",
    environment = var.environment,
    client      = var.client_name != "" ? var.client_name : "moove"
  }, var.labels)

  dynamic "lifecycle_rule" {
    for_each = [for rule in var.lifecycle_rules : {
      action_type          = rule.action.type
      action_storage_class = lookup(rule.action, "storage_class", null)

      condition_age                   = lookup(rule.condition, "age", null)
      condition_created_before        = lookup(rule.condition, "created_before", null)
      condition_with_state            = lookup(rule.condition, "with_state", null)
      condition_matches_storage_class = lookup(rule.condition, "matches_storage_class", null)
      condition_num_newer_versions    = lookup(rule.condition, "num_newer_versions", null)
    }]

    content {
      action {
        type          = lifecycle_rule.value.action_type
        storage_class = lifecycle_rule.value.action_storage_class
      }
      condition {
        age                   = lifecycle_rule.value.condition_age
        created_before        = lifecycle_rule.value.condition_created_before
        with_state            = lifecycle_rule.value.condition_with_state
        matches_storage_class = lifecycle_rule.value.condition_matches_storage_class
        num_newer_versions    = lifecycle_rule.value.condition_num_newer_versions
      }
    }
  }
}

data "google_storage_bucket" "bucket" {
  count = var.create_bucket ? 0 : 1
  name  = var.name
}

resource "google_storage_notification" "bucket-notification" {
  count              = var.notification_enabled ? 1 : 0
  bucket             = var.name
  payload_format     = "JSON_API_V1"
  topic              = google_pubsub_topic.topic[0].id
  event_types        = ["OBJECT_FINALIZE"]
  object_name_prefix = var.notification_prefix
  depends_on = [
    google_pubsub_topic_iam_member.binding,
  ]
}

# Pub/Sub 
resource "google_pubsub_topic" "topic" {
  count   = var.notification_enabled ? 1 : 0
  project = var.project_id
  name    = var.topic_name == "" ? var.name : var.topic_name
  labels = merge({
    terraformed = "true",
    environment = var.environment,
  }, var.labels)
}

resource "google_pubsub_topic_iam_member" "binding" {
  count   = var.notification_enabled ? 1 : 0
  project = google_pubsub_topic.topic[0].project
  topic   = google_pubsub_topic.topic[0].id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
  depends_on = [
    data.google_storage_project_service_account.gcs_account,
  ]
}

resource "google_pubsub_subscription" "subscription" {
  count                = var.subscription_enabled ? 1 : 0
  name                 = var.subscription_name == "" ? var.name : var.subscription_name
  project              = google_pubsub_topic.topic[0].project
  topic                = google_pubsub_topic.topic[0].id
  ack_deadline_seconds = var.ack_deadline_seconds
  labels = merge({
    terraformed = "true",
    environment = var.environment,
  }, var.labels)
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  count        = var.subscription_enabled ? 1 : 0
  subscription = google_pubsub_subscription.subscription[0].name
  project      = google_pubsub_subscription.subscription[0].project
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.create_service_account == true ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}"
}

resource "google_storage_bucket_iam_member" "admin" {
  for_each = toset(var.admin_members)
  bucket   = var.create_bucket == true ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  role     = "roles/storage.objectAdmin"
  member   = each.key
}

resource "google_storage_bucket_iam_member" "admin-legacy" {
  for_each = toset(var.admin_members)
  bucket   = var.create_bucket == true ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  role     = "roles/storage.legacyBucketOwner"
  member   = each.key
}

resource "google_storage_bucket_iam_member" "read" {
  for_each = toset(var.read_members)
  bucket   = var.create_bucket == true ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  role     = "roles/storage.objectViewer"
  member   = each.key
}

resource "google_storage_bucket_iam_member" "read-legacy" {
  for_each = toset(var.read_members)
  bucket   = var.create_bucket == true ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  role     = "roles/storage.legacyBucketReader"
  member   = each.key
}

resource "google_storage_bucket_iam_member" "sa-admin" {
  count  = var.admin_access ? 1 : 0
  bucket = var.create_bucket == true ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.create_service_account == true ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}"
}

resource "google_storage_bucket_iam_member" "sa-legacy" {
  count  = var.admin_access ? 1 : 0
  bucket = var.create_bucket == true ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  role   = "roles/storage.legacyBucketOwner"
  member = "serviceAccount:${var.create_service_account == true ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}"
}

resource "google_project_iam_binding" "sa_role_binding" {
  count   = var.cloud_function_enabled ? 1 : 0
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.create_service_account == true ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}",
  ]
}

data "google_project" "storage_transfer_project" {
  count      = var.storage_transfer_enabled ? 1 : 0
  project_id = var.storage_transfer_project
}

resource "google_storage_bucket_iam_member" "sts-legacy" {
  count  = var.storage_transfer_enabled ? 1 : 0
  bucket = var.create_bucket == true ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  role   = "roles/storage.legacyBucketOwner"
  member = "serviceAccount:project-${data.google_project.storage_transfer_project[0].number}@storage-transfer-service.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "sts-admin" {
  count  = var.storage_transfer_enabled ? 1 : 0
  bucket = var.create_bucket == true ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:project-${data.google_project.storage_transfer_project[0].number}@storage-transfer-service.iam.gserviceaccount.com"
}
