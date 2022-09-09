provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    proxy_url = "http://${google_compute_instance.gke-proxy.network_interface.0.network_ip}:8888"
    config_context = "gke_${var.project_id}_${var.region}_${module.gke.name}"
  }
}

provider "kubernetes" {
  alias = "internal"
  config_path = "~/.kube/config"
  proxy_url = "http://${google_compute_instance.gke-proxy.network_interface.0.network_ip}:8888"
  config_context_cluster = "gke_${var.project_id}_${var.region}_${module.gke.name}"
}

data "google_secret_manager_secret_version" "helm-key" {
  project = "moove-systems"
  secret = "helm_github-token"
}

resource "kubernetes_namespace" "monitoring" {
  provider = kubernetes.internal
  metadata {
    name = "monitoring"
    labels = {
      monitoring = "enabled"
    }
  }
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "kubernetes_namespace" "environment" {
  provider = kubernetes.internal
  metadata {
    name = var.environment
    labels = {
      monitoring = "enabled"
    }
  }
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "kubernetes_secret" "prometheus-secrets" {
  provider = kubernetes.internal
  metadata {
    name = "prometheus-secrets"
    namespace = "monitoring"
  }

  type = "Opaque"
  data = {
    "objstore.yml" = google_secret_manager_secret_version.thanos-object-store-config.secret_data
  }
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud,
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  version = "4.9.7"
  namespace = "default"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  values = [local.argocd_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  version = "1.6.1"
  namespace = "default"
  create_namespace = true
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  values = [local.cert_manager_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  version = "6.2.1"
  namespace = "default"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  values = [local.external_dns_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  version = "0.4.1"
  namespace = "default"
  create_namespace = true
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  values = [local.external_secrets_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}
