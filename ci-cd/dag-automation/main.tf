data "google_service_account" "deployer" {
  account_id = var.deployer_account_id
  project    = var.deployer_project_id
}

data "google_composer_environment" "staging_clusters" {
  for_each = { for idx, cluster in var.staging_clusters : idx => cluster }

  project = each.value.project_id
  name    = each.value.cluster_name
  region  = each.value.cluster_region
}

data "google_composer_environment" "production_clusters" {
  for_each = { for idx, cluster in var.production_clusters : idx => cluster }

  project = each.value.project_id
  name    = each.value.cluster_name
  region  = each.value.cluster_region
}

data "google_secret_manager_secret" "git-key" {
  project   = "moove-secrets"
  secret_id = "devops-bots-ssh-key"
}

resource "google_secret_manager_secret_iam_member" "git-key-member" {
  project   = "moove-secrets"
  secret_id = data.google_secret_manager_secret.git-key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = data.google_service_account.deployer.member
}

resource "google_storage_bucket_iam_member" "staging" {
  for_each = { for idx, cluster in var.staging_clusters : idx => cluster }

  bucket = trimsuffix(trimprefix(data.google_composer_environment.staging_clusters[each.key].config[0].dag_gcs_prefix, "gs://"), "/dags")
  member = data.google_service_account.deployer.member
  role   = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "production" {
  for_each = { for idx, cluster in var.production_clusters : idx => cluster }

  bucket = trimsuffix(trimprefix(data.google_composer_environment.staging_clusters[each.key].config[0].dag_gcs_prefix, "gs://"), "/dags")
  member = data.google_service_account.deployer.member
  role   = "roles/storage.objectAdmin"
}

resource "google_cloudbuild_trigger" "stage_trigger" {
  for_each = { for idx, cluster in var.staging_clusters : idx => cluster }

  project  = var.build_project_id
  name     = "stage-${var.github_repo}-dags-${each.value.cluster_name}"
  location = "global"

  service_account = data.google_service_account.deployer.id

  substitutions = {
    _DAGS_DIRECTORY = "dags/"
    _DAGS_BUCKET    = trimsuffix(trimprefix(data.google_composer_environment.staging_clusters[each.key].config[0].dag_gcs_prefix, "gs://"), "/dags")
  }

  github {
    owner = var.github_owner
    name  = var.github_repo

    pull_request {
      branch = var.stage_build_branch_pattern
    }
  }

  build {

    logs_bucket = "gs://moove-build-logs"

    # available_secrets {
    #   secret_manager {
    #     env          = "GITHUB_SSH_KEY"
    #     version_name = "projects/moove-secrets/secrets/devops-bots-ssh-key/versions/latest"
    #   }
    # }

    # step {
    #   name       = "gcr.io/cloud-builders/git"
    #   id         = "clone-composer-utils"
    #   entrypoint = "bash"
    #   secret_env = ["GITHUB_SSH_KEY"]
    #   args = ["-c", <<-EOF
    #     eval $(ssh-agent -s)
    #     echo "$$GITHUB_SSH_KEY"
    #     echo "$$GITHUB_SSH_KEY" | ssh-add -
    #     ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    #     git clone git@github.com:moove-ai/composer-utils.git /workspace/composer-utils
    #     EOF
    #   ]
    # }

    step {
      name       = "python:3.8-slim"
      entrypoint = "pip"
      args       = ["install", "-r", "dags/requirements-test.txt", "--user"]
    }

    step {
      name       = "python:3.8-slim"
      entrypoint = "python3.8"
      args       = ["-m", "pytest", "-s", "dags/"]
    }

    # step {
    #   name       = "python"
    #   entrypoint = "python"
    #   args       = ["/workspace/composer-utils/deploys/add_dags_to_composer.py", "--dags_directory=$${_DAGS_DIRECTORY}", "--dags_bucket=$${_DAGS_BUCKET}"]
    # }
  }
}


resource "google_cloudbuild_trigger" "deploy_trigger" {
  for_each = { for idx, cluster in var.production_clusters : idx => cluster }

  project  = var.build_project_id
  name     = "deploy-${var.github_repo}-dags-${each.value.cluster_name}"
  location = "global"

  service_account = data.google_service_account.deployer.id

  substitutions = {
    _DAGS_DIRECTORY = "dags/"
    _DAGS_BUCKET    = trimsuffix(trimprefix(data.google_composer_environment.staging_clusters[each.key].config[0].dag_gcs_prefix, "gs://"), "/dags")
  }

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = "main"
    }
  }

  build {
    logs_bucket = "gs://moove-build-logs"


    available_secrets {
      secret_manager {
        env          = "GITHUB_SSH_KEY"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-ssh-key/versions/latest"
      }
    }

    step {
      name       = "alpine"
      id         = "clone-composer-utils"
      entrypoint = "bash"
      secret_env = ["GITHUB_SSH_KEY"]
      args = ["-c", <<-EOF
        mkdir -p ~/.ssh
        echo "$$GITHUB_SSH_KEY" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        ssh-keyscan github.com >> ~/.ssh/known_hosts
        git clone git@github.com:moove-ai/composer-utils.git /workspace
        EOF
      ]
    }

    step {
      name       = "python"
      entrypoint = "python"
      args       = ["/workspace/composer-utils/deploys/add_dags_to_composer.py", "--dags_directory=$${_DAGS_DIRECTORY}", "--dags_bucket=$${_DAGS_BUCKET}"]
    }
  }
}
