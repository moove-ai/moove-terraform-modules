locals {
  argocd_values = var.argocd_values != "" ? var.argocd_values : <<-EOT
  configs:
    cm:
      create: true
      timeout.reconciliation: 0

  dex:
    enabled: false

  server:
    service:
      type: LoadBalancer
      annotations:
        cloud.google.com/load-balancer-type: Internal

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
        g, moove-admin, role:org-admin
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
    enabled: false
  EOT
}