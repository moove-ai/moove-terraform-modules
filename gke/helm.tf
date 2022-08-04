provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    proxy_url = "${var.proxy_dns}.${data.google_dns_managed_zone.moove.dns_name}"
    #config_context = "gke_moove-platform-dev_us-central1_dev-us-central1"
    config_context = module.gke.name
    #host = module.gke.endpoint
  }
}

resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  version = "4.9.7"
  namespace = "default"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

    values = [var.argo_cd_values]
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  version = "1.6.1"
  namespace = "default"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

    values = [var.cert_manager_values]
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  version = "6.2.1"
  namespace = "default"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

    values = [var.external_dns_values]
}

resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  version = "0.4.1"
  namespace = "default"

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

    values = [var.external_secrets_values]
}

