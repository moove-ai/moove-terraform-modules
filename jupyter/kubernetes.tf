resource "kubernetes_manifest" "hub-config" {
  manifest = yamldecode(<<-EOT
    apiVersion: external-secrets.io/v1alpha1
    kind: ExternalSecret
    metadata:
      name: hub-config
      namespace: ${var.namespace}
      labels:
        app: jupyterhub
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
          key: ${google_secret_manager_secret.hub-config.secret_id}
  EOT
  )
}

resource "kubernetes_manifest" "frontend-config" {
  manifest = yamldecode(<<-EOT
    apiVersion: networking.gke.io/v1beta1
    kind: FrontendConfig
    metadata:
      name: jupyter-https
      namespace: ${var.namespace}
    spec:
      redirectToHttps:
        enabled: true
        responseCodeName: MOVED_PERMANENTLY_DEFAULT
  EOT
  )
}

resource "kubernetes_manifest" "google-maps-api-key" {
  manifest = yamldecode(<<-EOT
    apiVersion: external-secrets.io/v1alpha1
    kind: ExternalSecret
    metadata:
      name: googlemaps-api-key
      namespace: ${var.namespace}
      labels:
        app: jupyterhub
        source: gcpsm
    spec:
      refreshInterval: 12h
      secretStoreRef:
        kind: ClusterSecretStore
        name: ${var.project_id}
      target:
        name: googlemaps-api-key
        creationPolicy: Owner
      data:
      - secretKey: gkey
        remoteRef:
          key: ${google_secret_manager_secret.hub-config.secret_id}
  EOT
  )
}