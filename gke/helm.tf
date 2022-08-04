provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    proxy_url = "${var.proxy_dns}.${data.google_dns_managed_zone.moove.dns_name}"
    config_context = "gke_moove-platform-dev_us-central1_dev-us-central1"
  }
}

resource "helm_release" "argocd" {
  name       = "argo-cd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

    values = [var.argo_values]
}
