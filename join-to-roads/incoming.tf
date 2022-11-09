data "google_storage_project_service_account" "wejo-gcs-sa" {
  project = var.wejo-import-bucket-us-project
}

resource "google_storage_bucket" "wejo-import-us-bucket" {
  name     = var.wejo-import-bucket-us
  project  = var.wejo-import-bucket-us-project
  location = "US"
  labels = merge(var.labels,
  {
    function = "data-import"
    project  = var.wejo-import-bucket-us-project
    data-provider = "wejo"
    trggers = "wejo-join-to-roads"
  })
}

resource "google_storage_bucket_iam_member" "jtr-read" {
  bucket = google_storage_bucket.wejo-import-us-bucket.name
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.k8s-join-to-roads.email}"
}

resource "google_pubsub_topic" "wejo-import-us-topic" {
  name    = google_storage_bucket.wejo-import-us-bucket.name
  project    = var.data-pipelines_project_id
}

resource "google_pubsub_topic_iam_binding" "wejo-import-us-iam-binding" {
  project    = var.data-pipelines_project_id
  topic      = google_pubsub_topic.wejo-import-us-topic.id
  role       = "roles/pubsub.publisher"
  members    = ["serviceAccount:${data.google_storage_project_service_account.wejo-gcs-sa.email_address}"]
  depends_on = [google_pubsub_topic.wejo-import-us-topic]
}

resource "google_storage_notification" "wejo-import-us-notification" {
  count = var.enable_notifications ? 1 : 0
  bucket         = google_storage_bucket.wejo-import-us-bucket.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.wejo-import-us-topic.id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on     = [google_pubsub_topic_iam_binding.wejo-import-us-iam-binding]
}

resource "google_pubsub_subscription" "wejo-import-us-join-to-roads-subscription" {
  name    = "${google_pubsub_topic.wejo-import-us-topic.name}-join-to-roads"
  project    = var.data-pipelines_project_id
  topic   = google_pubsub_topic.wejo-import-us-topic.name
  ack_deadline_seconds = 180
  labels = merge(var.labels,
  {
    function      = "data-import"
    data-provider = "wejo"
  })
}
