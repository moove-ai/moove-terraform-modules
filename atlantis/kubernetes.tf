provider "kubernetes" {
  config_path            = "~/.kube/config"
  proxy_url              = "http://${var.environment}-${var.region}.gke.moove.co.in:8888"
  config_context_cluster = "gke_${var.project_id}_${var.region}_${var.environment}-${var.region}"
}

resource "kubernetes_manifest" "atlantis-vcs-secrets" {
  manifest = yamldecode(<<-EOT
    apiVersion: external-secrets.io/v1alpha1
    kind: ExternalSecret
    metadata:
      name: atlantis-vcs-secrets
      namespace: ${var.deployment_namespace}
      labels:
        app: atlantis
        source: gcpsm
    spec:
      refreshInterval: 12h
      secretStoreRef:
        kind: ClusterSecretStore
        name: ${var.secret_project_id}
      target:
        name: atlantis-vcs-secrets
        creationPolicy: Owner
      data:
      - secretKey: github_token
        remoteRef:
          key: atlantis_github-token
      - secretKey: github_secret
        remoteRef:
          key: atlantis_github-secret
  EOT
  )
}

resource "kubernetes_manifest" "atlantis_git-config-secret" {
  manifest = yamldecode(<<-EOT
    apiVersion: external-secrets.io/v1alpha1
    kind: ExternalSecret
    metadata:
      name: atlantis-git-config-secret
      namespace: ${var.deployment_namespace}
      labels:
        app: atlantis
        source: gcpsm
    spec:
      refreshInterval: 12h
      secretStoreRef:
        kind: ClusterSecretStore
        name: ${var.secret_project_id}
      target:
        name: atlantis-git-config-secret
        creationPolicy: Owner
      data:
      - secretKey: gitconfig
        remoteRef:
          key: atlantis_git-config-secret
  EOT
  )
}

resource "kubernetes_manifest" "atlantis-gcp-sa-key" {
  manifest = yamldecode(<<-EOT
    apiVersion: external-secrets.io/v1alpha1
    kind: ExternalSecret
    metadata:
      name: atlantis-gcp-sa-key
      namespace: ${var.deployment_namespace}
      labels:
        app: atlantis
        source: gcpsm
    spec:
      refreshInterval: 12h
      secretStoreRef:
        kind: ClusterSecretStore
        name: ${var.secret_project_id}
      target:
        name: atlantis-terraform-gcp-sa-key
        creationPolicy: Owner
      data:
      - secretKey: gitconfig
        remoteRef:
          key: atlantis_gcp-sa-key
  EOT
  )
}
