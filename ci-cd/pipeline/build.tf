resource "google_cloudbuild_trigger" "build-template" {
  count           = var.build_file != "" ? 0 : 1
  name            = local.build_name
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"
  included_files  = local.build_included_files
  ignored_files   = local.build_ignored_files
  tags            = local.build_tags

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.build_branch_pattern
    }
  }

  build {
    logs_bucket = "gs://moove-build-logs"
    timeout     = var.build_timeout
    images = [
      "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA",
      "gcr.io/$PROJECT_ID/$REPO_NAME:cache",
    ]

    dynamic "options" {
      for_each = var.build_instance != "" ? [0] : []
      content {
        machine_type = var.build_instance
      }
    }

    # TODO enable java cache 
    # build java outside of Dockerfile
    # copy jar to Docker
    #dynamic "step" {
    #  for_each = var.java_build == true ? [0] : []
    #  content {
    #    id         = "download-maven-cache"
    #    wait_for   = ["build-container"]
    #    name       = "gcr.io/cloud-builders/gsutil"
    #    entrypoint = "bash"
    #    args       = ["-c", <<-EOF
    #      gsutil cp gs://moove-platform-production-cache-dependencies/cache/$REPO_NAME.tgz $REPO_NAME.tgz || exit 0 \
    #        tar -zxf $REPO_NAME.tgz --directory / || exit 0 
    #    EOF]
    #  }
    #}

    step {
      id         = "build-container"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"
      args = ["-c", <<-EOF
        ${local.build_args}
      EOF
      ]
    }

    dynamic "step" {
      for_each = var.unit_test_enabled == true ? [0] : []
      content {
        id         = "unit-tests"
        wait_for   = ["build-container"]
        name       = "gcr.io/cloud-builders/git"
        entrypoint = "bash"
        args = ["-c", <<-EOF
          ${local.unit_test_args}
        EOF
        ]
      }
    }

    step {
      id         = "push-cache"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"
      args = ["-c", <<-EOF
        docker push gcr.io/$PROJECT_ID/$REPO_NAME:cache
        echo 'pushed cache'
      EOF
      ]
    }
  }
}

resource "google_cloudbuild_trigger" "build-file" {
  count           = var.build_file != "" ? 1 : 0
  name            = local.build_name
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"
  included_files  = local.build_included_files
  ignored_files   = local.build_ignored_files
  tags            = local.build_tags

  filename = var.build_file

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.build_branch_pattern
    }
  }
}
