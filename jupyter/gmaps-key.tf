resource "google_project_service" "geocoding" {
  project = google_project.project.project_id
  service = "geocoding-backend.googleapis.com"
}

resource "google_secret_manager_secret" "googlemaps-api-key" {
  project = var.project_id
  secret_id = "jupyter-google_maps_api_key"

  replication {
    automatic = true
  }
}

resource "null_resource" "geocode" {
  provisioner "local-exec" {
    command = "chmod +x ${path.module}/get-gmaps-key.sh && sh ${path.module}/get-gmaps-key.sh"
    environment = {
      SERVICE_API = "geocoding-backend.googleapis.com"
      KEY_NAME = "gkey"
      SECRET_NAME = google_secret_manager_secret.googlemaps-api-key.secret_id
      PROJECT_ID = var.project_id
    }
  }

  depends_on = [
    google_secret_manager_secret.googlemaps-api-key,
    google_project_service.geocoding
  ]
}
