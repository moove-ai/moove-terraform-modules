resource "google_compute_global_network_endpoint_group" "neg" {
  name                  = var.neg_name
  project               = var.project_id
  default_port          = var.neg_default_port
  network_endpoint_type = var.network_endpoint_type
}

resource "google_compute_global_network_endpoint" "proxy" {
  provider                      = google-beta
  project                       = var.project_id
  global_network_endpoint_group = google_compute_global_network_endpoint_group.neg.id
  fqdn                          = google_api_gateway_gateway.api_gw.default_hostname
  port                          = google_compute_global_network_endpoint_group.neg.default_port
}

resource "google_compute_backend_service" "apigateway_lb_backend" {
  provider   = google-beta
  project    = var.project_id
  name       = var.backend_service_name
  protocol   = var.backend_service_protocol
  enable_cdn = true

  backend {
    group = google_compute_global_network_endpoint_group.neg.id
  }

  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }

  timeout_sec            = 10
  custom_request_headers = ["Host: ${google_api_gateway_gateway.api_gw.default_hostname}"]


  connection_draining_timeout_sec = 300
  session_affinity                = "NONE"
}

resource "google_compute_url_map" "urlmap" {
  name            = var.neg_name
  project         = var.project_id
  description     = var.load_balancer_description
  default_service = google_compute_backend_service.apigateway_lb_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.apigateway_lb_backend.id
  }
}

resource "google_compute_managed_ssl_certificate" "certificate" {
  project = var.project_id
  name    = "${var.neg_name}-certificate"

  managed {
    domains = [var.domain_name]
  }
}

resource "google_compute_target_https_proxy" "default" {
  name             = var.https_proxy_name
  project          = var.project_id
  url_map          = google_compute_url_map.urlmap.id
  ssl_certificates = [google_compute_managed_ssl_certificate.certificate.id]
}

resource "google_compute_global_forwarding_rule" "gateway_forwarding_rule" {
  name                  = "apigateway-forwarding-rule"
  project               = var.project_id
  ip_protocol           = "TCP"
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_https_proxy.default.self_link
}

data "google_dns_managed_zone" "zone" {
  name    = var.dns_zone
  project = var.dns_project
}

resource "google_dns_record_set" "example_a_record" {
  name         = "${var.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.zone.name
  project      = var.dns_project

  rrdatas = [google_compute_global_forwarding_rule.gateway_forwarding_rule.ip_address]
}
