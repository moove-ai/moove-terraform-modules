locals {
  app_path = var.ci_cd_name_override == "" ? "${var.gke_cluster}/${var.type}/${var.app_name}" : "${var.gke_cluster}/${var.type}/${var.ci_cd_name_override}"
  namespace = var.namespace != "" ? var.namespace : var.environment
}

resource "kubernetes_manifest" "app" {
  count = var.create_argo_app ? 1 : 0
  manifest = yamldecode(<<-EOT
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ${var.ci_cd_name_override == "" ? var.app_name : var.ci_cd_name_override}
      namespace: ${var.argo_app_namespace}
      annotations:
        argocd.argoproj.io/manifest-generate-paths: ${local.app_path}
        notifications.argoproj.io/subscribe.on-deployed.slack: devops-bot-test 
      labels:
        app.kubernetes.io/name: ${var.app_name}
        app.kubernetes.io/app: "true"
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      revisionHistoryLimit: ${var.revision_history}
      source:
        path: ${local.app_path}
        directory:
          recurse: true
        repoURL: git@github.com:moove-ai/k8s-git-ops.git
        targetRevision: ${var.target_revision}
      destination:
        server: https://kubernetes.default.svc
        namespace: ${local.namespace}
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
