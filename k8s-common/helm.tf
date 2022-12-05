data "google_secret_manager_secret_version" "helm-key" {
  project = "moove-systems"
  secret  = "helm_github-token"
}

data "google_secret_manager_secret_version" "devops-bots-ssh-key" {
  project = "moove-secrets"
  secret  = "devops-bots-ssh-key"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      monitoring = "enabled"
    }
  }
}

resource "kubernetes_namespace" "environment" {
  metadata {
    name = var.environment
    labels = {
      monitoring = "enabled"
    }
  }
}


resource "helm_release" "common-resources" {
  count            = var.install_common_resources ? 1 : 0
  name             = "common-resources"
  version          = "0.1.4"
  namespace        = "default"
  create_namespace = true
  repository       = "https://moove-helm-charts.storage.googleapis.com/"
  chart            = "common-resources"
  values           = [local.common_resources_values]
}

resource "helm_release" "cert-manager" {
  count            = var.install_cert_manager ? 1 : 0
  name             = "cert-manager"
  version          = "1.6.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  values           = [local.cert_manager_values]
}

resource "helm_release" "cert-manager-pilot" {
  count            = var.install_cert_manager_pilot ? 1 : 0
  name             = "cert-manager-pilot"
  version          = "0.1.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://moove-helm-charts.storage.googleapis.com/"
  chart            = "cert-manager-pilot"
  values           = [local.cert_manager_values]
  depends_on       = [helm_release.cert-manager]
}

resource "helm_release" "external-dns" {
  count            = var.install_external_dns ? 1 : 0
  name             = "external-dns"
  version          = "6.2.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  values           = [local.external_dns_values]
}

resource "helm_release" "external-secrets" {
  count            = var.install_external_secrets ? 1 : 0
  name             = "external-secrets"
  version          = "0.4.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  values           = [local.external_secrets_values]
}

resource "helm_release" "external-secrets-pilot" {
  count            = var.install_external_secrets_pilot ? 1 : 0
  name             = "external-secrets-pilot"
  version          = "0.1.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://moove-helm-charts.storage.googleapis.com/"
  chart            = "external-secrets-pilot"
  values           = [local.external_secrets_pilot_values]
  depends_on       = [helm_release.external-secrets]
}

resource "helm_release" "keda" {
  count            = var.install_keda ? 1 : 0
  name             = "keda"
  version          = "2.8.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  values           = [local.keda_values]
}
