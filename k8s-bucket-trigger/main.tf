data "google_storage_project_service_account" "gcs_account" {
  project = ${var.bucket_project == "" ? var.project_id : var.bucket_project}
}

resource "google_storage_bucket" "bucket" {
  count = var.create_input_bucket ? 1 : 0
  name = var.input_bucket
  project = ${var.bucket_project == "" ? var.project_id : var.bucket_project}
  location = var.bucket_location 
  labels = merge({
    "project" = var.project_id,
    "terraformed" = "true",
    "environment" = var.environment,
  },var.labels)
}

data "google_storage_bucket" "bucket" {
  count = var.create_input_bucket ? 0 : 1
  name = var.input_bucket
}

resource "google_pubsub_topic" "topic" {
  project = var.project_id
  name = ${var.topic_name == "" ? var.input_bucket : var.topic_name}
  labels = merge({
    "terraformed" = "true",
    "environment" = var.environment,
  }, var.labels)
}

resource "google_storage_notification" "bucket-notification" {
  count = var.notification_enabled ? 1 : 0
  bucket         = var.input_bucket
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.topic.id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on = [
    google_pubsub_topic_iam_binding.binding,
    ]
}

resource "google_pubsub_topic_iam_binding" "binding" {
  project = google_pubsub_topic.topic.project
  topic   = google_pubsub_topic.topic.id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
  depends_on = [
    data.google_storage_project_service_account.gcs_account,
  ]
}

resource "google_pubsub_subscription" "subscription" {
  name = ${var.subscription_name == "" ? var.input_bucket : var.subscription_name}
  topic = google_pubsub_topic.topic.id
  ack_deadline_seconds = var.ack_deadline_seconds
  labels = merge({
    "terraformed" = "true",
    "environment" = var.environment,
  }, var.labels)
}
