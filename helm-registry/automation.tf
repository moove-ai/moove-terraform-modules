data "google_service_account" "build_service_account" {
  project    = "moove-systems"
  account_id = "priviliged-builder"
}

resource "google_cloudbuild_trigger" "chart" {
  provider        = google-beta
  project         = "moove-systems"
  name            = "deploy-helm-charts"
  description     = "Updates the moove helm chart registry (charts.moove.co.in)"
  service_account = data.google_service_account.build_service_account.id

  tags = [ 
    "helm",
    "deploy",
  ]

  included_files = ["charts/*/Chart.yaml"]

  github {
    owner = "moove-ai"
    name  = "moove-helm"

    push {
      branch = "^main$"
    }
  }

  build {
    logs_bucket = "gs://moove-mgmt-build-logs"
    timeout     = "600s"

    options {
      machine_type = "UNSPECIFIED"
      volumes {
        name = "uploads"
        path = "/uploads"
      }
    }

    step {
      id   = "package-charts"
      name = "alpine/helm"
      entrypoint = "sh"
      args = [
        "-c", "helm package charts/*"
      ]
    }

    step {
      id   = "move-charts"
      name = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [
        "-c", "mv *.tgz /uploads"
      ]
    }

    step {
      id   = "index-charts"
      name = "alpine/helm"
      args = [
        "repo", "index", "/uploads",
         #"--url", "${google_storage_bucket.helm-registry-public.name}.storage.googleapis.com"
      ]
    }

    step {
      id   = "upload-charts"
      name = "gcr.io/cloud-builders/gcloud"
      entrypoint = "gsutil"
      args = [
        "rsync", "-r", "/uploads", google_storage_bucket.helm-registry-public.url
      ]
    }
  }
}
