locals {
  hub_config = <<EOT
  hub:
  config:
    GoogleOAuthenticator:
      client_id: ${google_iap_client.project_client.client_id}
      client_secret: ${google_iap_client.project_client.secret}
      oauth_callback_url: https://${var.jupyter_url}/hub/oauth_callback
      hosted_domain:
        - ${var.jupyter_domain}
      login_service: Moove AI
    JupyterHub:
      authenticator_class: google
EOT
}
