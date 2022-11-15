locals {
  data       = jsondecode(base64decode(google_service_account_key.monitor-key.private_key))
  key        = local.data.private_key
  datasource = <<-EOT
  apiVersion: 1
  datasources:
    - name: ${var.environment}
      type: stackdriver
      access: proxy
      jsonData:
        tokenUri: https://oauth2.googleapis.com/token
        clientEmail: ${google_service_account.monitor.email}
        authenticationType: jwt
        defaultProject: ${var.metrics_scope}
      secureJsonData:
        privateKey: 
          ${indent(10, local.key)}
  EOT
}
