#output "pubsub-topic" {
#  value       = google_pubsub_topic.topic[0].name
#  sensitive   = false
#  description = "The pub/sub topic"
#  depends_on  = []
#}
#
#output "pubsub-topic-id" {
#  value       = google_pubsub_topic.topic[0].id
#  sensitive   = false
#  description = "The pub/sub topic"
#  depends_on  = []
#}
#