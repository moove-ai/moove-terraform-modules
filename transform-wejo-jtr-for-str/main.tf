locals {
    namespace = ${var.namespace} == "" ? var.environment : var.namespace
}

module "trigger" {
  source = "../k8s-bucket-trigger"
  project_id = var.project_id
  input_bucket = var.input_bucket
  create_input_bucket = var.create_input_bucket
  bucket_location = var.input_bucket_location
  bucket_project = var.input_bucket_project
  labels = var.labels
  notification_enabled = var.notification_enabled
  ack_deadline_seconds = var.ack_deadline_seconds
  topic_name = var.topic_name
  subscription_name = var.subscription_name
}

resource "google_storage_bucket" "output-bucket" {
  name = var.output_bucket
  project = var.project_id
  location = var.output_bucket_location 
  labels = merge({
    "project" = var.project_id,
    "terraformed" = "true",
    "environment" = var.environment,
  },var.labels)
}

resource "google_service_account" "service-account" {
  project = var.project_id
  account_id = var.service_account_id
  display_name = "Transform Wejo JTR"
  description = "Service account used for the transform-wejo-jtr-for-str"
}

resource "google_storage_bucket_iam_member" "input-bucket-iam" {
  bucket = module.trigger.bucket
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_storage_bucket_iam_member" "output-bucket-iam" {
  bucket = google_storage_bucket.output-bucket.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  subscription = module.trigger.subscription
  role         = "roles/editor"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_service_account_iam_member" "workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.k8s_sa}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.service-account.name
}
