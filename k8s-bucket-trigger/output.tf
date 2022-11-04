output "bucket" {
  value       = var.create_input_bucket ? google_storage_bucket.bucket[0].name : data.google_storage_bucket.bucket[0].name
  sensitive   = false
  description = "The name of the bucket being used"
}

output "bucket-project" {
  value       = var.create_input_bucket ? google_storage_bucket.bucket[0].project : data.google_storage_bucket.bucket[0].project
  sensitive   = false
  description = "The project the bucket is in"
}

output "bucket-url" {
  value       = var.create_input_bucket ? google_storage_bucket.bucket[0].url : data.google_storage_bucket.bucket[0].url
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
