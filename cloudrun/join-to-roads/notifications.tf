# Create buckets
resource "google_storage_bucket" "input-bucket" {
  count    = var.create_input_bucket ? 1 : 0
  name     = var.input_bucket
  project  = var.project_id
  location = "US"
  labels = {
    function    = "data-input"
    project     = var.project_id
    environment = var.environment
  }
}

resource "google_storage_bucket" "output-bucket" {
  count    = var.create_output_bucket ? 1 : 0
  name     = var.output_bucket
  project  = var.project_id
  location = "US"
  labels = {
    function    = "jtr-output"
    project     = var.project_id
    environment = var.environment
  }
}

# Existing buckets
data "google_storage_bucket" "input-bucket" {
  count = var.create_input_bucket ? 0 : 1
  name  = var.input_bucket
}

data "google_storage_bucket" "output-bucket" {
  count = var.create_output_bucket ? 0 : 1
  name  = var.output_bucket
}

data "google_storage_project_service_account" "input-bucket-project" {
  project = var.create_input_bucket == false ? var.input_bucket_project : var.project_id
}

# Pub/Sub
resource "google_pubsub_topic" "input-notification-topic" {
  name    = var.create_input_bucket == false ? data.google_storage_bucket.input-bucket[0].name : google_storage_bucket.input-bucket[0].name
  project = var.project_id
}

resource "google_pubsub_topic_iam_binding" "input" {
  project    = var.project_id
  topic      = google_pubsub_topic.input-notification-topic.id
  role       = "roles/pubsub.publisher"
  members    = ["serviceAccount:${data.google_storage_project_service_account.input-bucket-project.email_address}"]
  depends_on = [google_pubsub_topic.input-notification-topic]
}

resource "google_pubsub_subscription" "input-subscription" {
  name                 = "${google_pubsub_topic.input-notification-topic.name}-join-to-roads"
  project              = var.project_id
  topic                = google_pubsub_topic.input-notification-topic.name
  ack_deadline_seconds = 180

  push_config {
    push_endpoint = google_cloud_run_service.service.status[0].url
    oidc_token {
      service_account_email = google_service_account.sa.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }

  labels = {
    function      = "data-input"
    data-provider = "wejo"
    client        = "saic"
    environment   = var.environment
  }
  depends_on = [google_pubsub_topic.input-notification-topic]
}


# Notifications
resource "google_storage_notification" "input-notification" {
  count          = var.enable_bucket_notification == false ? 0 : 1
  bucket         = var.create_input_bucket == false ? data.google_storage_bucket.input-bucket[0].name : google_storage_bucket.input-bucket[0].name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.input-notification-topic.id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on     = [google_pubsub_topic_iam_binding.input]
}

# Bucket IAM
resource "google_storage_bucket_iam_member" "wejo-input-iam" {
  bucket = var.create_input_bucket == false ? data.google_storage_bucket.input-bucket[0].name : google_storage_bucket.input-bucket[0].name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_storage_bucket_iam_member" "output-bucket-iam" {
  bucket = var.create_output_bucket == false ? data.google_storage_bucket.output-bucket[0].name : google_storage_bucket.output-bucket[0].name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.sa.email}"
}
