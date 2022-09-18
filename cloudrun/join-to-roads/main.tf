## Setup + Data
locals {
  service_account_display_name = "Cloud Run service account for the ${var.service_name} service"
  image                        = "gcr.io/${var.build_project_id}/${var.image_name}"
}

## Cloud Run Service
resource "google_cloud_run_service" "service" {
  name     = var.service_name
  project  = var.project_id
  location = var.region

  metadata {
    annotations = {
      "autoscaling.knative.dev/maxScale"        = "5"
      "run.googleapis.com/vpc-access-egress"    = "all"
      "run.googleapis.com/vpc-access-connector" = "${var.environment}-${var.region}"
      "run.googleapis.com/client-name"          = "terraform"
    }
  }

  template {
    spec {
      containers {
        image = local.image
        env {
          name  = "BATCH_SIZE"
          value = "10000"
        }
        env {
          name  = "MESSAGE_QUEUE_SIZE"
          value = "1"
        }
        env {
          name  = "MESSAGE_QUEUE_SIZE"
          value = "1"
        }
        env {
          name  = "MESSAGE_QUEUE_TIMEOUT"
          value = "540"
        }
        env {
          name  = "EXECUTOR_COUNT"
          value = "10"
        }
        env {
          name  = "SUBSCRIPTION_PROJECT"
          value = var.project_id
        }
        env {
          name  = "SUBSCRIPTION_ID"
          value = "${google_pubsub_topic.input-notification-topic.name}-join-to-roads"
        }
        env {
          name  = "AEROSPIKE_HOST"
          value = var.aerospike_host
        }
        env {
          name  = "OUTPUT_BUCKET"
          value = var.create_output_bucket == false ? data.google_storage_bucket.output-bucket[0].name : google_storage_bucket.output-bucket[0].name
        }
      }
    }
  }


  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = local.service_account_display_name
}

resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_service.service.location
  service  = google_cloud_run_service.service.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
}

resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_service_account.sa.email}"]
}