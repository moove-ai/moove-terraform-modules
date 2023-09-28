resource "google_project_service" "gateway" {
  service            = "apigateway.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "keys" {
  service            = "apikeys.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "service" {
  service            = "servicecontrol.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "gateway-service" {
  service            = google_api_gateway_api.api.managed_service
  project            = var.project_id
  disable_on_destroy = true
  depends_on = [
    google_api_gateway_api.api,
    google_api_gateway_api_config.api_cfg,
    google_api_gateway_gateway.api_gw,
  ]
}

resource "google_api_gateway_api" "api" {
  provider     = google-beta
  project      = var.project_id
  api_id       = var.app_id
  display_name = var.display_name
  labels = merge(var.labels,
    {
      app_id      = var.app_id,
      environment = var.environment,
  })
  depends_on = [google_project_service.gateway]
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider      = google-beta
  project       = var.project_id
  api           = google_api_gateway_api.api.api_id
  api_config_id = "${var.api_config_id}-${filemd5(var.open_api_document_file_path)}"

  openapi_documents {
    document {
      path     = var.open_api_document_filename
      contents = filebase64(var.open_api_document_file_path)
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [google_project_service.gateway]
}

resource "google_api_gateway_gateway" "api_gw" {
  provider   = google-beta
  project    = var.project_id
  region     = var.region
  api_config = google_api_gateway_api_config.api_cfg.id
  gateway_id = var.api_gateway_id
  depends_on = [google_project_service.gateway]
}
