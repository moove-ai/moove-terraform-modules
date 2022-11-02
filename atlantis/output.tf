output "service_account" {
  value       = google_service_account.atlantis.email
  sensitive   = false
  description = "The email address of the atlantis SA"
}
