locals {
  namespace = var.namespace == "" ? var.environment : var.namespace
  k8s_sa    = var.k8s_sa == "" ? var.app_name : var.k8s_sa
}

# Application
resource "google_service_account" "service-account" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Transform Wejo JTR"
  description  = "Service account used for the transform-wejo-jtr-for-str application"
}

resource "google_service_account_iam_member" "workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${local.k8s_sa}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.service-account.name
}

# Input Bucket
data "google_storage_project_service_account" "gcs_account" {
  project = var.input_bucket_project == "" ? var.project_id : var.input_bucket_project
}

resource "google_storage_bucket" "bucket" {
  count    = var.create_input_bucket ? 1 : 0
  name     = var.input_bucket
  project  = var.input_bucket_project == "" ? var.project_id : var.input_bucket_project
  location = var.input_bucket_location
  labels = merge({
    "project"     = var.project_id,
    "terraformed" = "true",
    "environment" = var.environment,
  }, var.labels)
}

data "google_storage_bucket" "bucket" {
  count = var.create_input_bucket ? 0 : 1
  name  = var.input_bucket
}

resource "google_storage_bucket_iam_member" "input-bucket-iam" {
  bucket = var.input_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.service-account.email}"
}


resource "google_storage_notification" "bucket-notification" {
  count          = var.notification_enabled ? 1 : 0
  bucket         = var.input_bucket
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.topic.id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on = [
    google_pubsub_topic_iam_binding.binding,
  ]
}

# Pub/Sub 
resource "google_pubsub_topic" "topic" {
  project = var.project_id
  name    = var.topic_name == "" ? var.input_bucket : var.topic_name
  labels = merge({
    "terraformed" = "true",
    "environment" = var.environment,
  }, var.labels)
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
  name                 = var.subscription_name == "" ? var.input_bucket : var.subscription_name
  topic                = google_pubsub_topic.topic.id
  ack_deadline_seconds = var.ack_deadline_seconds
  labels = merge({
    "terraformed" = "true",
    "environment" = var.environment,
  }, var.labels)
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  subscription = google_pubsub_subscription.subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.service-account.email}"
}

# Output Bucket 
resource "google_storage_bucket" "output-bucket" {
  count    = var.enable_output && var.create_output_bucket ? 1 : 0
  name     = var.output_bucket
  project  = var.output_bucket_project
  location = var.output_bucket_location
  labels = merge({
    "project"     = var.project_id,
    "terraformed" = "true",
    "environment" = var.environment,
  }, var.labels)
}

resource "google_storage_bucket_iam_member" "output-bucket-iam" {
  count  = var.enable_output ? 1 : 0
  bucket = var.output_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.service-account.email}"
}
