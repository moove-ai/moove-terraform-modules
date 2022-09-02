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

resource "kubernetes_namespace" "default" {
  provider = kubernetes.internal
  metadata {
    name = "default"
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
  }

  type = "Opaque"
  data = {
    "objstore.yml" = google_secret_manager_secret_version.thanos-object-store-config.secret_data
  }
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  version = "4.9.7"
  namespace = "default"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  values = [var.argo_cd_values]
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
  values = [var.cert_manager_values]
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
  values = [var.external_dns_values]
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
  values = [var.external_secrets_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  version = "35.0.3"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  values = [var.kube_prometheus_stack_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "blackbox-exporter" {
  count = var.prometheus_blackbox_exporter_values ? 1 : 0
  name       = "prometheus-blackbox-exporter"
  version = "5.8.1"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  values = [var.prometheus_blackbox_exporter_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "pushgateway" {
  count = var.prometheus_pushgateway_values ? 1 : 0
  name       = "prometheus-pushgateway"
  version = "1.16.1"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-pushgateway"
  values = [var.prometheus_pushgateway_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "stackdriver-exporter" {
  count = var.prometheus_stackdriver_exporter_values ? 1 : 0
  name       = "prometheus-stackdriver-exporter"
  version = "1.16.1"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-stackdriver-exporter"
  values = [var.prometheus_stackdriver_exporter_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}

resource "helm_release" "thanos" {
  name = "thanos"
  version = "10.4.2"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart = "thanos"
  values = [var.thanos_values]
  depends_on = [
    google_compute_instance.gke-proxy,
    module.gcloud
  ]
}
