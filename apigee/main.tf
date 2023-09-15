resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "apigee.googleapis.com"
}


#resource "google_compute_global_address" "apigee_range" {
#  name          = var.apigee_range_name
#  project      = var.project_id
#  purpose       = "VPC_PEERING"
#  address_type  = "INTERNAL"
#  prefix_length = var.apigee_range_prefix_length
#  network       = var.apigee_network_id
#}
#
#resource "google_service_networking_connection" "apigee_vpc_connection" {
#  network                 = var.apigee_network_id
#  service                 = "servicenetworking.googleapis.com"
#  reserved_peering_ranges = [google_compute_global_address.apigee_range.name]
#}
#
#resource "google_kms_key_ring" "apigee_keyring" {
#  name     = var.secret_name
#  project = var.secret_project_id
#  location = var.secret_region
#}
#
#resource "google_kms_crypto_key" "apigee_key" {
#  name            = var.secret_name
#  key_ring        = google_kms_key_ring.apigee_keyring.id
#
#  lifecycle {
#    prevent_destroy = true
#  }
#}
#
#resource "google_project_service_identity" "apigee_sa" {
#  provider = google-beta
#  project  = google_project.project.project_id
#  service  = google_project_service.apigee.service
#}
#
#resource "google_kms_crypto_key_iam_binding" "apigee_sa_keyuser" {
#  crypto_key_id = google_kms_crypto_key.apigee_key.id
#  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
#
#  members = [
#    "serviceAccount:${google_project_service_identity.apigee_sa.email}",
#  ]
#}
#
#resource "google_apigee_organization" "org" {
#  analytics_region                     = var.analytics_region
#  display_name                         = var.apigee_name
#  description                          = var.apigee_description
#  project_id                           = var.project_id
#  authorized_network                   = google_compute_network.apigee_network.id
#  runtime_database_encryption_key_name = google_kms_crypto_key.apigee_key.id
#
#  depends_on = [
#    google_service_networking_connection.apigee_vpc_connection,
#    google_kms_crypto_key_iam_binding.apigee_sa_keyuser,
#  ]
#}
#