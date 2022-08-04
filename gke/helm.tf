provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    proxy_url = "${var.proxy_dns}.${data.google_dns_managed_zone.moove.dns_name}"
    config_context = module.gke.name
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      monitoring = "enabled"
    }
  }
}

resource "kubernetes_namespace" "default" {
  metadata {
    name = "default"

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

resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  version = "4.9.7"
  namespace = "default"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  values = [var.argo_cd_values]
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  version = "1.6.1"
  namespace = "default"
  create_namespace = true
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  values = [var.cert_manager_values]
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  version = "6.2.1"
  namespace = "default"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  values = [var.external_dns_values]
}

resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  version = "0.4.1"
  namespace = "default"
  create_namespace = true
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  values = [var.external_secrets_values]
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  version = "35.0.3"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  values = [var.kube_prometheus_stack_values]
}

resource "helm_release" "blackbox-exporter" {
  count = var.helm_blackbox_exporter ? 1 : 0
  name       = "prometheus-blackbox-exporter"
  version = "5.8.1"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  values = [var.prometheus_blackbox_exporter_values]
}

resource "helm_release" "pushgateway" {
  count = var.helm_pushgateway ? 1 : 0
  name       = "prometheus-pushgateway"
  version = "1.16.1"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-pushgateway"
  values = [var.prometheus_pushgateway_values]
}

resource "helm_release" "stackdriver-exporter" {
  count = var.helm_stackdriver_exporter ? 1 : 0
  name       = "prometheus-stackdriver-exporter"
  version = "1.16.1"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-stackdriver-exporter"
  values = [var.prometheus_stackdriver_exporter_values]
}

resource "helm_release" "thanos" {
  name = "thanos"
  version = "10.4.2"
  namespace = "monitoring"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart = "thanos"
  values = [var.thanos_values]
}