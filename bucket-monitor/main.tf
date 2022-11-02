resource "google_storage_notification" "bucket-notification" {
  for_each = toset(var.bucket_names)
  bucket         = data.google_storage_bucket.existing-bucket[each.key].name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.topic[each.key].id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on = [
    google_pubsub_topic_iam_binding.binding,
    ]
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.bucket_project
}

resource "google_pubsub_topic_iam_binding" "binding" {
  for_each = toset(var.bucket_names)
  project = google_pubsub_topic.topic[each.key].project
  topic   = google_pubsub_topic.topic[each.key].id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
  depends_on = [
    data.google_storage_project_service_account.gcs_account,
  ]
}

resource "google_pubsub_topic" "topic" {
  for_each = toset(var.bucket_names)
  project = var.project_id
  name = each.key
  labels = {
    "env" = "mgmt",
    "function" = "bucket-monitor",
  }
}

resource "google_pubsub_subscription" "subscription" {
  for_each = toset(var.bucket_names)
  name  = each.key
  topic = google_pubsub_topic.topic[each.key].id
  ack_deadline_seconds = 120
  labels = {
    "env" = "mgmt",
    "function" = "bucket-monitor",
  }
}

data "google_storage_bucket" "existing-bucket" {
  for_each = toset(var.bucket_names)
  name = each.key
}
