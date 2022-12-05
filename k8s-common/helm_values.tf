locals {
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
