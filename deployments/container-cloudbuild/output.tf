output "id" {
  value = google_cloudbuild_trigger.trigger.id
  description = "The id (projects/{{project}}/locations/{{location}}/triggers/{{trigger_id}}) for this trigger"
}

output "trigger_id" {
  value = google_cloudbuild_trigger.trigger.trigger_id
  description = "The trigger_id for this trigger"
}
