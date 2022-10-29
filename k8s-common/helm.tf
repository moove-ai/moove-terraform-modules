#module "gcloud" {
#  source  = "terraform-google-modules/gcloud/google"
#  version = "~> 2.0"
#
#  skip_download = true
#
#  platform              = "linux"
#  additional_components = ["kubectl", "beta"]
#
#
#  create_cmd_entrypoint = "gcloud"
#  create_cmd_body       = "container clusters get-credentials ${var.cluster_name} --internal-ip --region=${var.region} --project=${var.project_id}"
#}

data "google_secret_manager_secret_version" "helm-key" {
  project = "moove-systems"
  secret  = "helm_github-token"
}

data "google_secret_manager_secret_version" "devops-bots-ssh-key" {
  project = "moove-secrets"
  secret  = "devops-bots-ssh-key"
}

data "google_secret_manager_secret_version" "argo-cd_k8s-git-ops-repo-url" {
  project = "moove-secrets"
  secret  = "argo-cd_k8s-git-ops-repo-url"
}

data "google_secret_manager_secret_version" "argo-cd_git-type" {
  project = "moove-secrets"
  secret  = "argo-cd_git-type"
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

resource "kubernetes_secret" "prometheus-secrets" {
  metadata {
    name      = "prometheus-secrets"
    namespace = "monitoring"
  }

  type = "Opaque"
  data = {
    "objstore.yml" = google_secret_manager_secret_version.thanos-object-store-config.secret_data
  }
  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "kubernetes_secret" "argocd-secrets" {
  metadata {
    name      = "k8s-git-ops-repo"
    namespace = "default"
    labels = {
      "app"                            = "argocd"
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"
  data = {
    "sshPrivateKey" = data.google_secret_manager_secret_version.devops-bots-ssh-key.secret_data
    "url"           = data.google_secret_manager_secret_version.argo-cd_k8s-git-ops-repo-url.secret_data
    "type"          = data.google_secret_manager_secret_version.argo-cd_git-type.secret_data
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "argo-cd" {
  name             = "argo-cd"
  version          = "4.9.7"
  namespace        = "default"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  values           = [local.argocd_values]
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  version          = "1.6.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  values           = [local.cert_manager_values]
}

resource "helm_release" "external-dns" {
  name             = "external-dns"
  version          = "6.2.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  values           = [local.external_dns_values]
}

resource "helm_release" "external-secrets" {
  name             = "external-secrets"
  version          = "0.4.1"
  namespace        = "default"
  create_namespace = true
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  values           = [local.external_secrets_values]
}
