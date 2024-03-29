locals {
  transformed_client_list = [for client in var.client_list : replace(replace(client, "@", "-"), ".", "_")]
  aggregated_secrets = {
    for client in var.client_list :
    client => jsondecode(data.google_secret_manager_secret_version.client_secret_versions[client].secret_data)[client]
  }
}

resource "random_password" "api_key" {
  for_each = toset(local.transformed_client_list)

  length  = 40
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_shuffle" "api_key_shuffled" {
  for_each = toset(local.transformed_client_list)

  input        = [random_password.api_key[each.key].result]
  result_count = 1
}


resource "google_secret_manager_secret" "client_secrets" {
  for_each = toset(local.transformed_client_list)

  project   = var.project_id
  secret_id = "contextualization_key_${each.key}"

  replication {
    auto {}
  }

  labels = {
    client      = each.key
    application = "moove-webserivce"

  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_secret_manager_secret_version" "client_secret_versions" {
  for_each = toset(local.transformed_client_list)

  secret          = google_secret_manager_secret.client_secrets[each.key].name
  secret_data     = "{\"${each.key}\": \"${random_shuffle.api_key_shuffled[each.key].result[0]}\"}"
  deletion_policy = "DISABLE"

}

# Fetch individual secrets for each client
data "google_secret_manager_secret_version" "client_secret_versions" {
  for_each = toset(local.transformed_client_list)
  depends_on = [
    google_secret_manager_secret.client_secrets,
    google_secret_manager_secret_version.client_secret_versions,
  ]

  secret  = google_secret_manager_secret.client_secrets[each.key].name
  version = "latest"
}

# Create main aggregated secret
resource "google_secret_manager_secret" "aggregated_secret" {
  project   = var.project_id
  secret_id = var.api_key_main_secret_name

  replication {
    auto {}
  }

  labels = {
    application = "moove-webserivce"
    function    = "contextualization-main-api-key-dictionary"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Store aggregated secret dictionary into the main secret
resource "google_secret_manager_secret_version" "aggregated_secret_version" {
  depends_on = [google_secret_manager_secret.client_secrets]

  secret          = google_secret_manager_secret.aggregated_secret.name
  secret_data     = jsonencode(local.aggregated_secrets)
  deletion_policy = "DISABLE"
}

resource "google_secret_manager_secret_iam_member" "aggregated_secret_iam" {
  secret_id = google_secret_manager_secret.aggregated_secret.name
  role      = "roles/secretmanager.secretAccessor"
  member    = module.gke-app.service_account_member
}
