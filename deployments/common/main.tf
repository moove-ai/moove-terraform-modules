resource "google_service_account" "builder" {
    account_id = "builder"
    display_name = "Cloud Build Builder"
    description = "Service account used to run Cloud Build"
    project = var.project_id
}

resource "google_service_account" "privileged-builder" {
    account_id = "privileged-builder"
    display_name = "Privileged Cloud Build Builder"
    description = "Service account used to run Cloud Build with access to secrets"
    project = var.project_id
}
