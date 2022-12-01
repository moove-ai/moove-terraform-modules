resource "kubernetes_manifest" "atlantis-vcs-secrets" {
  manifest = yamldecode(<<-EOT
    apiVersion: external-secrets.io/v1alpha1
    kind: ExternalSecret
    metadata:
      name: hub-config
      namespace: ${var.namespace}
      labels:
        app: atlantis
        source: gcpsm
    spec:
      refreshInterval: 12h
      secretStoreRef:
        kind: ClusterSecretStore
        name: ${var.project_id}
      target:
        name: hub-config
        creationPolicy: Owner
      data:
      - secretKey: values.yaml
        remoteRef:
          key: ${google_secret_manager_secret.hub-config.name}
  EOT
  )
}
