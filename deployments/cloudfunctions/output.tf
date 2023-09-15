output "trigger_url" {
  value       = var.function_trigger_topic != "" ? "https://${var.function_region}-${var.function_project_id}.cloudfunctions.net/${var.function_name}" : null
  sensitive   = false
  description = "The URL of the CF"
  depends_on  = []
}

output "trigger_topic" {
  value       = var.function_trigger_topic != "" ? var.function_trigger_topic : null
  sensitive   = false
  description = "The topic which triggers the CF"
  depends_on  = []
}

output "function_name" {
  value       = var.function_name
  sensitive   = false
  description = "The topic which triggers the CF"
  depends_on  = []
}
