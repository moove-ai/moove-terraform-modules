data "google_secret_manager_secret_version" "argo-cd_k8s-git-ops-repo-url" {
  project = "moove-secrets"
  secret  = "argo-cd_k8s-git-ops-repo-url"
}

data "google_secret_manager_secret_version" "argo-cd_git-type" {
  project = "moove-secrets"
  secret  = "argo-cd_git-type"
}

data "google_secret_manager_secret_version" "slack-token" {
  project = "moove-secrets"
  secret  = "argo-cd_slack-token"
}

data "google_secret_manager_secret_version" "grafana-api-key" {
  project = "moove-secrets"
  secret  = "ci-cd_grafana-token"
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

resource "kubernetes_secret" "argocd-notifications-secret" {
  metadata {
    name      = local.notification_secret
    namespace = "default"
    labels = {
      "app"                            = "argocd"
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"
  data = {
    "slack-token"     = data.google_secret_manager_secret_version.slack-token.secret_data
    "grafana-api-key" = data.google_secret_manager_secret_version.grafana-api-key.secret_data
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "argo-cd" {
  count            = var.install_argocd ? 1 : 0
  name             = "argo-cd"
  version          = "4.9.7"
  namespace        = "default"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  values           = [local.argocd_values]
}

locals {
  notification_secret = "argocd-notifications-secret"
  argocd_values       = var.argocd_values != "" ? var.argocd_values : <<-EOT
  dex:
    enabled: false

  server:
    service:
      type: LoadBalancer
      annotations:
        external-dns.alpha.kubernetes.io/hostname: "${var.environment}.deployments.moove.co.in"
        cloud.google.com/load-balancer-type: Internal

    resources:
      limits:
        cpu: 2
        memory: 2Gi
      requests:
        cpu: 500m
        memory: 512Mi

    config:
      url: "https://${var.environment}.deployments.moove.co.in"
      accounts.moove: apiKey, login

    extraArgs:
      - --insecure

    rbacConfig:
      policy.csv: |
        p, role:org-admin, applications, *, */*, allow
        p, role:org-admin, clusters, get, *, allow
        p, role:org-admin, repositories, get, *, allow
        p, role:org-admin, repositories, create, *, allow
        p, role:org-admin, repositories, update, *, allow
        p, role:org-admin, repositories, delete, *, allow
        p, role:deploy-user, applications, get, */*, allow
        p, role:deploy-user, applications, sync, */*, allow
        p, role:deploy-user, applications, update, */*, allow
        p, role:deploy-user, clusters, get, *, allow
        p, role:deploy-user, repositories, get, *, allow
        g, moove, role:org-admin
        g, alex, role:org-admin
      policy.default: role:''

  redis:
    resources:
      limits:
        cpu: 500m
        memory: 512Mi
      requests:
        cpu: 100m
        memory: 64Mi

  repoServer:
    resources:
      limits:
        cpu: 2
        memory: 2Gi
      requests:
        cpu: 500m
        memory: 512Mi

  notifications:
    enabled: true
    name: notifications-controller
    argocdUrl: "https://${var.environment}.deployments.moove.co.in"

    resources: {}

    serviceAccount:
      create: true
      name: argocd-notifications-controller
      annotations: {}

    cm:
      create: true
      name: "argocd-notifications-cm"

    secret:
      create: false
      name: "${local.notification_secret}"

    notifiers:
      service.grafana: |
        apiUrl: https://grafana.moove.ai/api
        apiKey: $grafana-api-key
      service.slack: |
        token: $slack-token

    templates:
      template.slack-success: |
        message: |
          Deployment Success ({{.app.metadata.name}})!

    triggers:
      trigger.custom-deployed: |
        - when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
          oncePer: app.status.sync.revision
          send: [slack-success]

  EOT
}
