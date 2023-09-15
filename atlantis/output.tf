output "email" {
  value       = google_service_account.atlantis.email
  sensitive   = false
  description = "The email address of the atlantis SA"
}

output "app_name" {
  value       = var.app_name
  sensitive   = false
  description = "The name of application"
}

output "atlantis_github_token" {
  value       = google_secret_manager_secret_version.atlantis_github-token-version.secret_data
  sensitive   = true
  description = "The github token for atlantis"
}

output "atlantis_github_secret" {
  value       = google_secret_manager_secret_version.atlantis_github-secret-version.secret_data
  sensitive   = true
  description = "The github secret for atlantis"
}

output "atlantis_git_config_secret" {
  value       = google_secret_manager_secret_version.atlantis_git-config-secret-version.secret_data
  sensitive   = true
  description = "The git config secret"
}
