resource "google_storage_bucket_iam_member" "input-bucket-iam" {
  bucket = var.input_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.create_service_account ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}"
}

resource "google_storage_bucket_iam_member" "input-bucket-legacy-iam" {
  bucket = var.input_bucket
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${var.create_service_account ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}"
}

resource "google_storage_bucket_iam_member" "output-bucket-legacy-reader-iam" {
  count  = var.enable_output ? 1 : 0
  bucket = var.output_bucket
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${var.create_service_account ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}"
}

resource "google_storage_bucket_iam_member" "output-bucket-iam" {
  count  = var.enable_output ? 1 : 0
  bucket = var.output_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.create_service_account ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}"
}

resource "google_storage_bucket_iam_member" "output-bucket-legacy-iam" {
  count  = var.enable_output ? 1 : 0
  bucket = var.output_bucket
  role   = "roles/storage.legacyObjectOwner"
  member = "serviceAccount:${var.create_service_account ? google_service_account.service-account[0].email : data.google_service_account.service-account[0].email}"
}
