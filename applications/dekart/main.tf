data "google_compute_network" "network" {
  project = var.network_project_id
  name    = "${var.environment}-vpc"
}

resource "google_sql_database" "database" {
  count      = var.create_database ? 1 : 0
  depends_on = [google_sql_database_instance.dekart]

  project  = var.project_id
  name     = var.database_name
  instance = google_sql_database_instance.dekart[0].name
}

resource "google_sql_database_instance" "dekart" {
  count            = var.create_database ? 1 : 0
  project          = var.project_id
  name             = var.database_instance_name
  region           = var.region
  database_version = var.database_version


  settings {
    tier = var.database_tier
    ip_configuration {
      ipv4_enabled    = true
      private_network = data.google_compute_network.network.id
    }
  }
  deletion_protection = var.deletion_protection
}


resource "google_service_account" "dekart" {
  project    = var.project_id
  account_id = var.dekart_serviceaccount
}

resource "google_service_account_key" "dekart-key" {
  depends_on = [google_service_account.dekart]

  service_account_id = google_service_account.dekart.name
}

resource "google_secret_manager_secret" "dektart-sa" {
  project   = var.project_id
  secret_id = "dekart_serviceaccount"

  labels = {
    environment = var.environment
    function    = "dekart"
    terraformed = "true"
  }

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "dekart-key" {
  depends_on = [
    google_service_account_key.dekart-key,
    google_secret_manager_secret.dektart-sa
  ]

  secret      = google_secret_manager_secret.dektart-sa.id
  secret_data = base64decode(google_service_account_key.dekart-key.private_key)
}


resource "google_organization_iam_member" "dekart" {
  for_each = toset(var.dekart_org_roles)
  org_id   = var.org_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.dekart.email}"
}

resource "google_project_iam_member" "dekart" {
  for_each = toset(var.dekart_project_roles)
  project  = var.dekart_bq_project
  role     = each.value
  member   = "serviceAccount:${google_service_account.dekart.email}"
}

resource "random_string" "postfix" {
  length  = 6
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "google_storage_bucket" "dekart" {
  count         = var.create_bucket ? 1 : 0
  project       = var.project_id
  name          = "moove-dekart-${var.environment}"
  location      = var.region
  force_destroy = true
}

data "google_storage_bucket" "dekart" {
  count = var.create_bucket ? 0 : 1
  name  = var.bucket_name
}

resource "google_storage_bucket_iam_member" "dekart-iam" {
  bucket = var.create_bucket ? google_storage_bucket.dekart[0].name : data.google_storage_bucket.dekart[0].name
  member = "serviceAccount:${google_service_account.dekart.email}"
  role   = "roles/storage.objectAdmin"
}
