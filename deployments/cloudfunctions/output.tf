output trigger_url {
  count = var.function_trigger_topic == "" ? 1 : 0
  value       = "https://${var.region}-${var.function_project_id}.cloudfunctions.net/${var.function_name}"
  sensitive   = false
  description = "The URL of the CF"
  depends_on  = []
}

output trigger_topic {
  count = var.function_trigger_topic == "" ? 0 : 1
  value       = var.function_trigger_topic
  sensitive   = false
  description = "The topic which triggers the CF"
  depends_on  = []
}

output function_name {
  value       = var.function_name
  sensitive   = false
  description = "The topic which triggers the CF"
  depends_on  = []
}
