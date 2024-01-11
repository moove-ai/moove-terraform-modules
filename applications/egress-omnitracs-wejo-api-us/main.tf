resource "google_secret_manager_secret" "access" {
  project   = var.project_id
  secret_id = "wejo_api_access_key"
  labels    = var.labels

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret" "secret" {
  project   = var.project_id
  secret_id = "wejo_api_secret_access_key"
  labels    = var.labels

  replication {
    auto {
    }
  }
}
