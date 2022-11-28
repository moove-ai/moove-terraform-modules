resource "kubernetes_manifest" "egress-secrets" {
  manifest = yamldecode(<<-EOT
    apiVersion: external-secrets.io/v1alpha1
    kind: ExternalSecret
    metadata:
      name: ${var.k8s_secret_name}
      namespace: ${var.namespace}
      labels:
        function: data-pipelines
        source: gcpsm
    spec:
      refreshInterval: 12h
      secretStoreRef:
        kind: ClusterSecretStore
        name: ${var.project_id}
      target:
        name: ${var.k8s_secret_name}
        creationPolicy: Owner
      data:
      - secretKey: aws_access_key
        remoteRef:
          key: ${google_secret_manager_secret.aws-access-key.secret_id}
      - secretKey: aws_secret_access_key
        remoteRef:
          key: ${google_secret_manager_secret.aws-secret-access-key.secret_id}
      - secretKey: gcp_access_key
        remoteRef:
          key: ${google_secret_manager_secret.gcp-access-key.secret_id}
      - secretKey: gcp_secret_access_key
        remoteRef:
          key: ${google_secret_manager_secret.gcp-secret-access-key.secret_id}
  EOT
  )
}
