#data "google_cloud_run_service" "service" {
#  for_each = var.create_external_load_balancer ? toset(var.regions) : []
#  project  = var.cloud_run_project != "" ? var.cloud_run_project : var.project_id
#  name     = var.cloud_run_service_name
#  location = each.key
#}
#
#resource "google_compute_global_network_endpoint_group" "neg" {
#  count                 = var.create_external_load_balancer ? length(var.regions) : 0
#  name                  = "${var.cloud_run_service_name}-${element(var.regions, count.index)}"
#  network_endpoint_type = "INTERNET_FQDN_PORT"
#  global                = true
#  endpoint {
#    fqdn = data.google_cloud_run_service.service.status[element(var.regions, count.index)].url
#    port = "443"
#  }
#}
#
#resource "google_compute_managed_ssl_certificate" "managed_ssl" {
#  count = var.create_external_load_balancer ? 1 : 0
#  name  = "${var.cloud_run_service_name}-ssl"
#  managed {
#    domains = [var.domain_name]
#  }
#}
#
#resource "google_compute_global_backend_service" "backend_service" {
#  count     = var.create_external_load_balancer ? 1 : 0
#  name      = var.cloud_run_service_name
#  port_name = "https"
#  protocol  = "HTTP"
#  dynamic "backend" {
#    for_each = toset(var.regions)
#    content {
#      group = element(google_compute_global_network_endpoint_group.neg.*.self_link, backend.key)
#    }
#  }
#}
#
#resource "google_compute_url_map" "url_map" {
#  count           = var.create_external_load_balancer ? 1 : 0
#  name            = "${var.cloud_run_service_name}-url-map"
#  default_service = google_compute_global_backend_service.backend_service[0].self_link
#}
#
#resource "google_compute_target_https_proxy" "https_proxy" {
#  count            = var.create_external_load_balancer ? 1 : 0
#  name             = "${var.cloud_run_service_name}-https-proxy"
#  url_map          = google_compute_url_map.url_map[0].self_link
#  ssl_certificates = [google_compute_managed_ssl_certificate.managed_ssl[0].self_link]
#}
#
#resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
#  count       = var.create_external_load_balancer ? 1 : 0
#  name        = "${var.cloud_run_service_name}-forwarding-rule"
#  target      = google_compute_target_https_proxy.https_proxy[0].self_link
#  ip_protocol = "TCP"
#  port_range  = "443"
#}
#
#data "google_dns_managed_zone" "managed_zone" {
#  count   = var.create_external_load_balancer ? 1 : 0
#  project = var.dns_project
#  name    = var.dns_zone
#}
#
#resource "google_dns_record_set" "frontend" {
#  count        = var.create_external_load_balancer ? 1 : 0
#  name         = var.dns_name
#  type         = "A"
#  ttl          = 300
#  managed_zone = data.google_dns_managed_zone.managed_zone[0].name
#  rrdatas      = [google_compute_global_forwarding_rule.global_forwarding_rule[0].ip_address]
#  depends_on   = [google_compute_global_forwarding_rule.global_forwarding_rule]
#}
#