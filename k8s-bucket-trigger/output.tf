output "input_bucket" {
  value       = var.create_input_bucket ? google_storage_bucket.input-bucket[0].name : data.google_storage_bucket.input-bucket[0].name
  sensitive   = false
  description = "The name of the bucket being used"
}

output "output_bucket" {
  value       = var.enable_output ? var.output_bucket : "null"
  sensitive   = false
  description = "The name of the bucket being used"
}

output "input_bucket_project" {
  value       = local.input_bucket_project
  sensitive   = false
  description = "The project the bucket is in"
}

output "output_bucket_project" {
  value       = var.enable_output ? local.output_bucket_project : "null"
  sensitive   = false
  description = "The project the bucket is in"
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

output "app_name" {
  value       = var.app_name
  sensitive   = false
  description = "The name of the application"
}

output "project_id" {
  value       = var.project_id
  sensitive   = false
  description = "The project_id"
}

output "namespace" {
  value       = var.namespace
  sensitive   = false
  description = "The namespace the app is deployed in"
}

output "service_account" {
  value       = google_service_account.service-account.email
  sensitive   = false
  description = "The email for the service account created"
}