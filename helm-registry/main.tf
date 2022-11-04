resource "google_storage_bucket" "helm-registry-public" {
  project                     = "moove-systems"
  name                        = "moove-helm-charts"
  location                    = "US"
  uniform_bucket_level_access = false
  force_destroy               = true
  public_access_prevention    = "inherited"
}


resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.helm-registry-public.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_iam_member" "automation" {
  bucket = google_storage_bucket.helm-registry-public.name
  role   = "roles/storage.admin"
  member = "serviceAccount:privileged-builder@moove-systems.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "public" {
  bucket = google_storage_bucket.helm-registry-public.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
