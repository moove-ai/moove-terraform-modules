output "builder_sa" {
    value = google_service_account.builder.email
    description = "The email address of the 'builder' service account"
}

output "builder_sa_name" {
    value = google_service_account.builder.name
    description = "The name of the 'builder' service account"
}
