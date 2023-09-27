resource "google_project_iam_member" "reader" {
  project = var.build_project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.atlantis.email}"
}

resource "google_cloudbuild_trigger" "build-template" {
  name            = "build-atlantis"
  project         = var.build_project_id
  service_account = "projects/${var.build_project_id}/serviceAccounts/deployer@${var.build_project_id}.iam.gserviceaccount.com"
  included_files  = ["Dockerfile"]
  ignored_files   = []
  tags            = ["atlantis", "build"]

  github {
    owner = "moove-ai"
    name  = "atlantis"
    push {
      branch = "main"
    }
  }

  build {
    logs_bucket = "gs://moove-build-logs"
    timeout     = "600s"
    images = [
      "us-docker.pkg.dev/$PROJECT_ID/docker-us/$REPO_NAME:latest",
      "us-docker.pkg.dev/$PROJECT_ID/docker-us/$REPO_NAME:$SHORT_SHA",
    ]

    available_secrets {
      secret_manager {
        env          = "SLACK_HOOK"
        version_name = "projects/moove-secrets/secrets/cicd-slack-deploys-hook/versions/latest"
      }
    }

    step {
      id         = "build-container"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"
      args = ["-c", <<-EOF
        docker build . \
          -t us-docker.pkg.dev/$PROJECT_ID/docker-us/$REPO_NAME:$SHORT_SHA \
          -t us-docker.pkg.dev/$PROJECT_ID/docker-us/$REPO_NAME:latest \
      EOF
      ]
    }

    step {
      id         = "send-slack-build"
      name       = "gcr.io/cloud-builders/gcloud"
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

