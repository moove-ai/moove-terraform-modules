/**
 * # Jupyter
 *
 * This module sets up resources around Jupyter and JupyterHub
 * You must assign a GCP admin role to the serviceaccount running this terraform.
 * Details here: [Assigning an admin role to the serviceaccount](https://cloud.google.com/identity/docs/how-to/setup#assigning_an_admin_role_to_the_service_account)
 * 
 *
 * Written by Alex Merenda for moove.ai
 */


resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.service_account_id
  description  = "Service account running jupyter. k8s namespace: ${var.namespace}, k8s sa: ${var.k8s_sa_name}"
  display_name = var.service_account_name
}

resource "google_service_account_iam_member" "sa-workload-identity" {
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${var.k8s_sa_name}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.sa.name
}