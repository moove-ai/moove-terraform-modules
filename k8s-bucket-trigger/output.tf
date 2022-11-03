output "bucket" {
  value       = "${var.create_input_bucket ? data.google_storage_bucket.bucket.name : google_storage_bucket.bucket.name}"
  sensitive   = false
  description = "The name of the bucket being used"
}

output "bucket-project" {
  value       = "${var.create_input_bucket ? data.google_storage_bucket.bucket.project : google_storage_bucket.bucket.project}"
  sensitive   = false
  description = "The project the bucket is in"
}

output "bucket-url" {
  value       = "${var.create_input_bucket ? data.google_storage_bucket.bucket.url : google_storage_bucket.bucket.url}"
  sensitive   = false
  description = "The url (gs://<name>) of the bucket"
}

output "topic" {
  value       = google_pubsub_topic.topic.name
  sensitive   = false
  description = "The name of the topi"
}

output "subscription" {
  value       = google_pubsub_subscription.subscription.name
  sensitive   = false
  description = "The name of the subscription"
}
