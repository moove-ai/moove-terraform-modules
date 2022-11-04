locals {
  datasource = <<-EOT
  apiVersion: 1
    datasources:
      - name: ${var.environment}
        type: stackdriver
        access: proxy
        uid: production
        jsonData:
          tokenUri: https://oauth2.googleapis.com/token
          clientEmail: ${google_service_account.monitor.email}
          authenticationType: jwt
          defaultProject: ${var.metrics_scope}
        secureJsonData:
          privateKey: 
            ${indent(10, base64decode(google_service_account_key.monitor-key.private_key))}
  EOT
}
