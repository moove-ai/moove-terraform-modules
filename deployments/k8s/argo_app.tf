resource "kubernetes_manifest" "app" {
  manifest = yamldecode(<<-EOT
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ${var.app_name}
      namespace: "default"
      annotations:
        notifications.argoproj.io/subscribe.on-deployed.grafana: "app|${var.app_name}"
      labels:
        app.kubernetes.io/name: ${var.app_name}
        app.kubernetes.io/app: "true"
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      revisionHistoryLimit: ${var.revision_history}
      source:
        path: ${var.gke_cluster}/${var.type}/${var.app_name}
        directory:
          recurse: true
        repoURL: git@github.com:moove-ai/k8s-git-ops.git
        targetRevision: ${var.target_revision}
      destination:
        server: https://kubernetes.default.svc
        namespace: ${var.namespace}
      syncPolicy:
        automated:
          prune: ${var.prune}
          selfHeal: ${var.self_heal}
        syncOptions:
          - CreateNamespace=${var.create_namespace}
          - RespectIgnoreDifferences=${var.respect_ignore_differences}
  EOT
  )
}
