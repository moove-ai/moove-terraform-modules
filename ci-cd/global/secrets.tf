resource "google_secret_manager_secret" "argocd-ssh-key" {
  project   = "moove-secrets"
  secret_id = "argocd_ssh-key"

  labels = {
    environment = "mgmt"
    function    = "argocd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "argocd-ssh-key-iam-member" {
  project   = google_secret_manager_secret.argocd-ssh-key.project
  secret_id = google_secret_manager_secret.argocd-ssh-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_secret_manager_secret" "argocd-devopsbot-password" {
  project   = "moove-secrets"
  secret_id = "argocd_devopsbot_password"

  labels = {
    environment = "mgmt"
    function    = "argocd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "argocd-devopsbot-password-iam-member" {
  project   = google_secret_manager_secret.argocd-devopsbot-password.project
  secret_id = google_secret_manager_secret.argocd-devopsbot-password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_secret_manager_secret" "argocd-moove-password" {
  project   = "moove-secrets"
  secret_id = "argocd_moove_password"

  labels = {
    environment = "mgmt"
    function    = "argocd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "argocd-moove-password-iam-member" {
  project   = google_secret_manager_secret.argocd-moove-password.project
  secret_id = google_secret_manager_secret.argocd-moove-password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_secret_manager_secret" "argocd-alex-password" {
  project   = "moove-secrets"
  secret_id = "argocd_alex_password"

  labels = {
    environment = "mgmt"
    function    = "argocd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "argocd-alex-password-iam-member" {
  project   = google_secret_manager_secret.argocd-alex-password.project
  secret_id = google_secret_manager_secret.argocd-alex-password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_secret_manager_secret" "cicd-slack-hook" {
  project   = "moove-secrets"
  secret_id = "cicd-slack-deploys-hook"

  labels = {
    environment   = "mgmt"
    function      = "cicd"
    slack_channel = "deploys"
    client        = "moove"
    terraformed   = "true"
    secret-data   = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "cicd-slack-hook-iam-member" {
  project   = google_secret_manager_secret.cicd-slack-hook.project
  secret_id = google_secret_manager_secret.cicd-slack-hook.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_secret_manager_secret" "argocd-token" {
  project   = "moove-secrets"
  secret_id = "argocd_token"

  labels = {
    environment = "mgmt"
    function    = "argocd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "argocd-token-iam-member" {
  project   = google_secret_manager_secret.argocd-token.project
  secret_id = google_secret_manager_secret.argocd-token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployer.email}"
}
