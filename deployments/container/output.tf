output "id" {
  value       = google_cloudbuild_trigger.build-container.id
  description = "The id (projects/{{project}}/locations/{{location}}/triggers/{{trigger_id}}) for this trigger"
}

output "trigger_id" {
  value       = google_cloudbuild_trigger.build-container.trigger_id
  description = "The trigger_id for this trigger"
}
