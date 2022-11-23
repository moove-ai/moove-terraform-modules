locals {
argocd_values = var.argocd_values != "" ? var.argocd_values : <<-EOT
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
    argocdUrl: "https://${var.environment}.deployments.moove.c.in"

    secret:
      create: false
      name: "argocd-notifications-secret"

    notifiers:
      service.grafana: |
        apiUrl: https://grafana.moove.ai/api
        apiKey: $grafana-api-key

    resources: {}

    serviceAccount:
      create: true
      name: argocd-notifications-controller
      annotations: {}

    cm:
      create: true
      name: "argocd-notifications-cm"

    templates:
      template.grafana-app-deployed: |
        title: "{{call .git.GetCommitMetadata .app.status.sync.revision}}"
        body: |
          Application details: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}.

      template.app-deployed: |
        email:
          subject: New version of an application {{.app.metadata.name}} is up and running.
        message: |
          {{if eq .serviceType "slack"}}:white_check_mark:{{end}} Application {{.app.metadata.name}} is now running {{call .git.GetCommitMetadata .app.status.sync.revision}}.
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
              }
              {{range $index, $c := .app.status.conditions}}
              {{if not $index}},{{end}}
              {{if $index}},{{end}}
              {
                "title": "{{$c.type}}",
                "value": "{{$c.message}}",
                "short": true
              }
              {{end}}
              ]
            }]
        body: |
          Commit: "{{call .git.GetCommitMetadata .app.status.sync.revision}}"
          Application details: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}.
      template.app-sync-succeeded: |
        title: Application {{.app.metadata.name}} successfully deployed
        body: |
          Commit: "{{call .git.GetCommitMetadata .app.status.sync.revision}}"
          Application details: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}.


    triggers:
      trigger.on-deployed: |
        - description: Application is synced and healthy. Triggered once per commit.
          oncePer: app.status.sync.revision
          send:
          - app-deployed
          - grafana-app-deployed
          when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
      trigger.on-health-degraded: |
        - description: Application has degraded
          send:
          - app-health-degraded
          when: app.status.health.status == 'Degraded'
      trigger.on-sync-failed: |
        - description: Application syncing has failed
          send:
          - app-sync-failed
          when: app.status.operationState.phase in ['Error', 'Failed']
      trigger.on-sync-running: |
        - description: Application is being synced
          send:
          - app-sync-running
          when: app.status.operationState.phase in ['Running']
      trigger.on-sync-status-unknown: |
        - description: Application status is 'Unknown'
          send:
          - app-sync-status-unknown
          when: app.status.sync.status == 'Unknown'
      trigger.on-sync-succeeded: |
        - description: Application syncing has succeeded
          send:
          - app-sync-succeeded
          when: app.status.operationState.phase in ['Succeeded']
  EOT

  cert_manager_values = var.cert_manager_values != "" ? var.cert_manager_values : <<-EOT
  clusterResourceNamespace: "cert-manager"
  installCRDs: true
  replicaCount: 1

  global:
    logLevel: 2
    leaderElection:
      namespace: "default"

  image:
    repository: quay.io/jetstack/cert-manager-controller
    pullPolicy: IfNotPresent

  serviceAccount:
    create: true
    name: cert-manager
    automountServiceAccountToken: true
    labels:
      argocd: "worked-with-helm"
    annotations:
      iam.gke.io/gcp-service-account: dns-admin@moove-systems.iam.gserviceaccount.com

  extraArgs:
    - --cluster-resource-namespace=default

  resources:
     requests:
       cpu: 10m
       memory: 32Mi

  prometheus:
    enabled: true
    servicemonitor:
      enabled: false
      prometheusInstance: prometheus
      targetPort: 9402
      path: /metrics
      interval: 60s
      scrapeTimeout: 30s
      labels: {}
  EOT

  cert_manager_pilot_values = var.cert_manager_pilot_values != "" ? var.cert_manager_pilot_values : <<-EOT
  pilot:
  clusterIssuer:
    staging:
      enabled: true
    live:
      enabled: true
  EOT

  external_dns_values = var.external_dns_values != "" ? var.external_dns_values : <<-EOT
  clusterDomain: cluster.local

  sources:
    - service
    - ingress
  provider: google

  google:
    project: moove-systems
  interval: "1m"
  replicaCount: 1
  crd:
    create: false
  service:
    enabled: true
    type: ClusterIP
  serviceAccount:
    create: true
    name: external-dns
    annotations:
      iam.gke.io/gcp-service-account: "dns-admin@moove-systems.iam.gserviceaccount.com"
    automountServiceAccountToken: true
  resources:
    requests:
      cpu: 50m
      memory: 100Mi
    limits:
      cpu: 200m
      memory: 256Mi
    EOT

  external_secrets_values = var.external_secrets_values != "" ? var.external_secrets_values : <<-EOT
  serviceAccount:
    create: true
    annotations:
      iam.gke.io/gcp-service-account: k8s-secrets@${var.project_id}.iam.gserviceaccount.com
    name: "k8s-secrets"
  EOT

  external_secrets_pilot_values = var.external_secrets_pilot_values != "" ? var.external_secrets_pilot_values : <<-EOT
  pilot:
    secretStores:
      - ${var.project_id}
      - moove-secrets
  EOT

  common_resources_values = var.common_resources_values != "" ? var.common_resources_values : <<-EOT
  EOT

  keda_values = var.keda_values != "" ? var.keda_values : <<-EOT
  serviceAccount:
    create: true
    annotations:
      iam.gke.io/gcp-service-account: k8s-keda@${var.project_id}.iam.gserviceaccount.com
  EOT
}
