resource "google_service_account" "builder" {
    account_id = "builder"
    display_name = "Cloud Build Builder"
    description = "Service account used to run Cloud Build"
    project = var.project_id
}