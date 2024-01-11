# Local variables
locals {
  contextualization_service_account_project = var.contextualization_service_account_project != "" ? var.contextualization_service_account_project : var.project_id
}

# The contextualization service account
data "google_service_account" "contextualization-service-account" {
  project    = local.contextualization_service_account_project
  account_id = var.contextualization_service_account_name
}

# Creates the contextualization store service account resources
module "gke-app" {
  source = "../../gke-app"

  create_service_account       = var.create_service_account
  service_account_display_name = var.service_account_display_name
  service_account_description  = var.service_account_description
  service_account_id           = var.service_account_id
  gke_project_id               = var.gke_project_id
  environment                  = var.environment
  gke_service_account_name     = var.gke_service_account_name
  project_id                   = var.project_id
}

# The contextualization store pubsub topic
resource "google_pubsub_topic" "topic" {
  project = var.project_id

  name = var.pubsub_topic_name
  labels = {
    environment = var.environment
    application = "contextualization-store"
  }
}

# IAM member for the topic using the contextualization service account
resource "google_pubsub_topic_iam_member" "topic-iam" {
  project = google_pubsub_topic.topic.project

  topic  = google_pubsub_topic.topic.name
  role   = "roles/pubsub.publisher"
  member = data.google_service_account.contextualization-service-account.member
}

# IAM Member for the topic using the gke-app service account
resource "google_pubsub_topic_iam_member" "gke-topic-iam" {
  project = google_pubsub_topic.topic.project

  topic  = google_pubsub_topic.topic.name
  role   = "roles/pubsub.publisher"
  member = module.gke-app.service_account_member
}

# The contextualization store pubsub subscription
resource "google_pubsub_subscription" "subscription" {
  project = var.project_id

  name                 = var.pubsub_subscription_name
  topic                = google_pubsub_topic.topic.name
  ack_deadline_seconds = var.ack_deadline_seconds
  labels = {
    environment = var.environment
    application = "contextualization-store"
  }
}

# IAM member for the subscription using the gke-app service account
resource "google_pubsub_subscription_iam_member" "subscription-iam" {
  project = google_pubsub_subscription.subscription.project

  subscription = google_pubsub_subscription.subscription.name
  role         = "roles/pubsub.subscriber"
  member       = module.gke-app.service_account_member
}

# The storage bucket where the contextualization data will be stored
resource "google_storage_bucket" "bucket" {
  project = var.project_id

  name     = var.contextualization_store_bucket
  location = var.contextualization_store_location

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

resource "google_storage_bucket_iam_member" "bucket-iam" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectAdmin"
  member = module.gke-app.service_account_member
}

resource "google_project_iam_member" "legacy-bucket-iam" {
  project = var.project_id
  role    = "roles/viewer"
  member  = module.gke-app.service_account_member
}
