data "google_storage_project_service_account" "project" {
  project = var.data-pipelines_project_id
}

resource "google_storage_bucket" "moove-wejo-jtr-output-us" {
  location = "US"
  name     = var.wejo-jtr-output-bucket-us
  project  = var.wejo-jtr-output-bucket-project-us
  labels = merge(var.labels,
    {
    function = "data-pipelines"
    project    = var.data-pipelines_project_id
    private  = "true"
    triggers = "transform-wejo-jtr-for-str"
    data-source = "wejo-join-to-roads"
  })
}

resource "google_storage_bucket_iam_member" "jtr-write" {
  bucket = google_storage_bucket.wejo-import-us-bucket.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.k8s-join-to-roads.email}"
}

resource "google_pubsub_topic" "moove-wejo-jtr-output-us-topic" {
  name    = google_storage_bucket.moove-wejo-jtr-output-us.name
  project    = var.data-pipelines_project_id
}

# Binding for transformed wejo data notifications
resource "google_pubsub_topic_iam_binding" "moove-wejo-jtr-output-us-iam-binding" {
  project = google_pubsub_topic.moove-wejo-jtr-output-us-topic.project
  topic   = google_pubsub_topic.moove-wejo-jtr-output-us-topic.id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.project.email_address}"]
}

# Notification for transformed wejo data
resource "google_storage_notification" "moove-wejo-jtr-output-us-notification" {
  count = var.enable_notifications ? 1 : 0
  bucket         = google_storage_bucket.moove-wejo-jtr-output-us.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.moove-wejo-jtr-output-us-topic.id
  event_types    = ["OBJECT_FINALIZE", "OBJECT_METADATA_UPDATE"]
  depends_on     = [google_pubsub_topic_iam_binding.moove-wejo-jtr-output-us-iam-binding]
}
