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

    step {
      id         = "cache"
      wait_for   = ["-"]
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "/bin/bash"
      args = ["-c", <<-EOF
        docker pull gcr.io/$PROJECT_ID/$REPO_NAME:cache || exit 0
        EOF
      ]
    }

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
        name       = "gcr.io/cloud-builders/docker"
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

    step {
      id         = "send-slack-build"
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "/bin/bash"
      secret_env = ["SLACK_HOOK"]
      args = ["-c", <<-EOT
        export name=$(cat /workspace/name.txt)
        export version=$(cat /workspace/version.txt)
        echo $$name
        echo $$version
        cat << EOF > payload.json
          {
          	"blocks": [
          		{
          			"type": "section",
          			"text": {
          				"type": "mrkdwn",
          				"text": ":white_check_mark: Image Built + Tested: $REPO_NAME | Branch: $BRANCH_NAME"
          			}
          		},
          		{
          			"type": "divider"
          		},
          		{
          			"type": "section",
          			"fields": [
          				{
          					"type": "mrkdwn",
          					"text": "*User:*\n$(cat /workspace/git_user.txt)"
          				},
          				{
          					"type": "mrkdwn",
          					"text": "*Email:*\n$(cat /workspace/git_email.txt)"
          				},
          				{
          					"type": "mrkdwn",
          					"text": "*Message:*\n$(cat /workspace/git_message.txt)"
          				},
          				{
          					"type": "mrkdwn",
          					"text": "*Git Link:*\n<https://github.com/moove-ai/$REPO_NAME/commit/$COMMIT_SHA|$SHORT_SHA>"
          				}
          			]
          		}
          	]
          }
        EOF

        curl -XPOST $$SLACK_HOOK \
        -H "Content-type: application/json" \
        --data @payload.json
      EOT
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
