output "hostname" {
  value = google_api_gateway_gateway.api_gw.default_hostname
}

output "managed_service" {
  description = "The managed service of the Google API Gateway API."
  value       = google_api_gateway_api.api.managed_service
}
