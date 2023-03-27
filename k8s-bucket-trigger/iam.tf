resource "google_storage_bucket_iam_member" "input-bucket-iam" {
  bucket = var.input_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_storage_bucket_iam_member" "input-bucket-legacy-iam" {
  bucket = var.input_bucket
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_storage_bucket_iam_member" "output-bucket-legacy-reader-iam" {
  count  = var.enable_output ? 1 : 0
  bucket = var.output_bucket
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_storage_bucket_iam_member" "output-bucket-iam" {
  count  = var.enable_output ? 1 : 0
  bucket = var.output_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_storage_bucket_iam_member" "output-bucket-legacy-iam" {
  count  = var.enable_output ? 1 : 0
  bucket = var.output_bucket
  role   = "roles/storage.legacyObjectOwner"
  member = "serviceAccount:${google_service_account.service-account.email}"
}

resource "google_service_account_iam_member" "workload-identity" {
  for_each           = toset(var.regions)
  member             = "serviceAccount:${local.cluster_project_id}.svc.id.goog[${local.namespace}/join-to-roads-${var.environment}-${each.key}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.service-account.name
}
