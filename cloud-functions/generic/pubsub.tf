resource "google_pubsub_topic" "topic" {
  count                      = var.create_topic ? 1 : 0
  project                    = var.project_id
  name                       = local.pubsub_topic_name
  message_retention_duration = var.pubsub_topic_message_retention_duration
  labels = {
    environment = var.environment
    function    = var.application_name
  }
}

resource "google_pubsub_subscription" "subscription" {
  count = var.create_subscription ? 1 : 0
  name  = local.pubsub_subscription_name
  topic = google_pubsub_topic.topic[0].name

  labels = {
    environment = var.environment
    function    = var.application_name
  }

  message_retention_duration = var.pubsub_subscription_message_retention_duration
  retain_acked_messages      = var.pubsub_retain_acked_messages

  ack_deadline_seconds = var.pubsub_ack_deadline_seconds

  dynamic "expiration_policy" {
    for_each = var.pubsub_expiration_policy != null ? [var.pubsub_expiration_policy] : []
    content {
      ttl = expiration_policy.value["ttl"]
    }
  }

  dynamic "retry_policy" {
    for_each = var.pubsub_retry_policy != null ? [var.pubsub_retry_policy] : []
    content {
      minimum_backoff = retry_policy.value["minimum_backoff"]
    }
  }

  enable_message_ordering = var.pubsub_enable_message_ordering
}

resource "google_pubsub_subscription_iam_member" "publisher" {
  count        = var.create_subscription ? 1 : 0
  subscription = google_pubsub_subscription.subscription[0].name
  role         = "roles/pubsub.publisher"
  member       = "serviceAccount:${var.create_service_account ? google_service_account.runner[0].email : data.google_service_account.runner[0].email}"
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  count        = var.create_subscription ? 1 : 0
  subscription = google_pubsub_subscription.subscription[0].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.create_service_account ? google_service_account.runner[0].email : data.google_service_account.runner[0].email}"
}
