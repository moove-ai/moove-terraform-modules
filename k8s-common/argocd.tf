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
  version          = "5.16.2"
  namespace        = "default"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  values           = [local.argocd_values]
}


locals {
  argocd_url = "${var.environment}.deployments.moove.co.in"
  notification_secret = "argocd-notifications-secret"
  argocd_values       = var.argocd_values != "" ? var.argocd_values : <<-EOT
  dex:
    enabled: false

  server:
    ingress:
      enabled: true
      annotations:
        external-dns.alpha.kubernetes.io/hostname: ${local.argocd_url}
        kubernetes.io/ingress.class: "gce-internal"
        kubernetes.io/ingress.allow-http: false
        cert-manager.io/cluster-issuer: "letsencrypt"
      hosts:
        - ${local.argocd_url}
      pathType: Prefix
      tls:
        - secretName: argocd-tls
          hosts:
            - ${local.argocd_url}
      https: true

    service:
      type: NodePort
      annotations:
        cloud.google.com/neg: '{"ingress": true}'

    extraArgs:
      - --insecure

    resources:
      limits:
        cpu: 4
        memory: 4Gi
      requests:
        cpu: 2
        memory: 2Gi

    config:
      url: "${local.argocd_url}"
      accounts.moove: apiKey, login

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
    argocdUrl: "${local.argocd_url}"

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
    
    context:
      environment: ${var.environment}
      region: ${var.region}

    notifiers:
      service.grafana: |
        apiUrl: https://grafana.moove.ai/api
        apiKey: $grafana-api-key
      service.slack: |
        token: $slack-token

    triggers:
      trigger.on-deployed: |
        - description: Application is synced and healthy. Triggered once per commit.
          oncePer: app.status.operationState.syncResult.revision
          send:
          - app-deployed
          when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'

    templates:
      template.app-deployed: |
        message: |
          {{if eq .serviceType "slack"}}:white_check_mark:{{end}} Application {{.app.metadata.name}} deployed to ${var.environment}-${var.region}
        slack:
          attachments: |
            [{
              "title": "{{ .app.metadata.name}}",
              "title_link":"{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
              "color": "#18be52",
              "fields": [
              {
                "title": "Sync Status",
                "value": "{{.app.status.sync.status}}",
                "short": true
              },
              {
                "title": "Repository",
                "value": "{{.app.spec.source.repoURL}}",
                "short": true
              },
              {
                "title": "Revision",
                "value": "{{.app.status.sync.revision}}",
                "short": true
              }]
            }]
  EOT
}
