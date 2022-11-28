resource "google_secret_manager_secret" "aws-access-key" {
  project = var.project_id
  secret_id = "egress-transformed-jtr-to-saic-s3-us_aws_access_key"
  labels = var.labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "aws-secret-access-key" {
  project = var.project_id
  secret_id = "egress-transformed-jtr-to-saic-s3-us_aws_secret_access_key"
  labels = var.labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "gcp-access-key" {
  project = var.project_id
  secret_id = "egress-transformed-jtr-to-saic-s3-us_gcp_access_key"
  labels = var.labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "gcp-secret-access-key" {
  project = var.project_id
  secret_id = "egress-transformed-jtr-to-saic-s3-us_gcp_secret_access_key"
  labels = var.labels

  replication {
    automatic = true
  }
}

resource "google_storage_hmac_key" "gcp-key" {
  project = var.project_id
  service_account_email = var.gcp_service_account
}
