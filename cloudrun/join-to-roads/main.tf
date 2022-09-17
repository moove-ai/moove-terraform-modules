locals {
  serviceaccount_display_name = "Cloud Run service account for the ${var.service_name} service"
  image = "gcr.io/${var.build_project_id}/${var.image_name}"
}

data "google_storage_project_service_account" "data-import-pipelines" {
  project = "moove-data-import-pipelines"
}

resource "google_cloud_run_service" "join-to-roads-service" {
    name     = var.service_name
    location = var.region
    template {
      spec {
            containers {
                image = local.image
            }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = "${var.environment}-${var.region}"
      }
    }

    traffic {
      percent         = 100
      latest_revision = true
    }
}

resource "google_service_account" "sa" {
  account_id   = var.serviceaccount_id
  display_name = local.serviceaccount_display_name
}

resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_service.default.location
  service = google_cloud_run_service.default.name
  role = "roles/run.invoker"
  members = ["serviceAccount:${google_service_account.sa.email}"]
}

resource "google_project_iam_binding" "project" {
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_service_account.sa.email}"]
}

resource "google_pubsub_topic" "wejo-import-us-topic" {
  name    = "moove-ax4j9z-data-import-us"
  project = var.project_id
}

resource "google_pubsub_topic_iam_binding" "wejo-import-us-iam-binding" {
  project    = var.project_id
  topic      = google_pubsub_topic.wejo-import-us-topic.id
  role       = "roles/pubsub.publisher"
  members    = ["serviceAccount:${data.google_storage_project_service_account.data-import-pipelines.email_address}"]
  depends_on = [google_pubsub_topic.wejo-import-us-topic]
}

resource "google_storage_notification" "wejo-import-us-notification" {
  bucket         = google_storage_bucket.wejo-import-us-bucket.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.wejo-import-us-topic.id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on     = [google_pubsub_topic_iam_binding.wejo-import-us-iam-binding]
}

resource "google_pubsub_subscription" "wejo-import-us-join-to-roads-subscription" {
  name    = "${google_pubsub_topic.wejo-import-us-topic.name}-join-to-roads"
  project = var.project_id
  topic   = google_pubsub_topic.wejo-import-us-topic.name
  ack_deadline_seconds = 180

  push_config {
    push_endpoint = google_cloud_run_service.default.status[0].url
    oidc_token {
      service_account_email = google_service_account.sa.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }

  labels = {
    function      = "data-import"
    data-provider = "wejo"
    client        = "saic"
    environment   = var.environment
  }
}
