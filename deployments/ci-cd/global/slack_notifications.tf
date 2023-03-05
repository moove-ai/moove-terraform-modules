data "google_project" "project" {
  project_id = "moove-builds-a747"
}

resource "google_service_account" "notifier" {
  project = data.google_project.project.project_id
  account_id = "notifier"
}

resource "google_project_service" "cloud-run" {
  project = data.google_project.project.project_id
  service = "run.googleapis.com"
}

resource "google_project_iam_member" "invoker" {
  project = data.google_project.project.project_id
  role = "roles/run.invoker"
  member = "serviceAccount:${google_service_account.notifier.email}"
}

resource "google_project_iam_member" "service-account-user" {
  project = data.google_project.project.project_id
  role = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_storage_bucket" "notifications" {
  name = "moove-build-notifications"
  project = data.google_project.project.project_id
  location = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "notifier-iam" {
  bucket = google_storage_bucket.notifications.name
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.notifier.email}"
}

resource "google_storage_bucket_object" "slack" {
  name   = "slack.json"
  bucket = google_storage_bucket.notifications.name
  content = local.slack_config
}

resource "google_storage_bucket_object" "notifier" {
  name   = "notifier.yaml"
  bucket = google_storage_bucket.notifications.name
  content = local.notifier_config
}

resource "google_secret_manager_secret" "ci-cd-slack-builds-hook" {
  project   = "moove-secrets"
  secret_id = "ci-cd_slack-builds-hook"

  labels = {
    environment = "mgmt"
    function    = "cicd"
    client      = "moove"
    terraformed = "true"
    secret-data = "manual-input"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "ci-cd-slack-builds-iam-member" {
  project   = google_secret_manager_secret.ci-cd-slack-builds-hook.project
  secret_id = google_secret_manager_secret.ci-cd-slack-builds-hook.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.notifier.email}"
}

resource "google_pubsub_topic" "topic" {
  project = data.google_project.project.project_id
  name    = "cloud-builds"
  labels = {
    terraformed = "true",
    environment = "mgmt",
    function    = "cicd"
  }
}

resource "google_pubsub_subscription" "subscription" {
  name                 = "cloud-build-subscriber"
  project              = google_pubsub_topic.topic.project
  topic                = google_pubsub_topic.topic.id
  ack_deadline_seconds = "60"
  labels = {
    terraformed = "true",
    environment = "mgmt"
    function    = "cicd"
  }
  push_config {
    push_endpoint = google_cloud_run_service.build-notifier.status[0].url

    oidc_token {
      service_account_email = google_service_account.notifier.email
      audience = google_cloud_run_service.build-notifier.status[0].url
    }

    attributes = {
      x-goog-version = "v1"
    }
  }
}

resource "google_cloud_run_service" "build-notifier" {
  name     = "build-notifier"
  project = data.google_project.project.project_id
  location = "us-central1"

  template {
    spec {
      service_account_name = google_service_account.notifier.email
      containers {
        image = "us-east1-docker.pkg.dev/gcb-release/cloud-build-notifiers/slack:latest"
        env {
          name  = "CONFIG_PATH"
          value = "${google_storage_bucket.notifications.url}/${google_storage_bucket_object.notifier.output_name}"
        }
        env {
          name  = "PROJECT_ID"
          value = "moove-systems"
        }        
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "auth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.notifier.email}",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "auth" {
  location    = google_cloud_run_service.build-notifier.location
  project     = google_cloud_run_service.build-notifier.project
  service     = google_cloud_run_service.build-notifier.name

  policy_data = data.google_iam_policy.auth.policy_data
}


locals {
  notifier_config = <<EOT
    apiVersion: cloud-build-notifiers/v1
    kind: SlackNotifier
    metadata:
      name: slack-notifier
    spec:
      notification:
        filter: build.status in [Build.Status.SUCCESS, Build.Status.FAILURE, Build.Status.TIMEOUT]
        params:
          buildStatus: $(build.status)
        delivery:
          webhookUrl:
            secretRef: webhook-url
        template:
          type: golang
          uri: gs://${google_storage_bucket.notifications.name}/slack.json
      secrets:
      - name: webhook-url
        value: projects/moove-secrets/secrets/ci-cd_slack-builds-hook/versions/latest  
  EOT
  slack_config = <<EOT
	  [
	  	{
	  		"type": "section",
	  		"text": {
	  			"type": "plain_text",
	  			"text": "{{.Build.Substitutions.REPO_NAME}} - {{.Build.Substitutions.BRANCH_NAME}}: {{.Build.Status}}"
	  		},
	  		"accessory": {
	  			"type": "image",
	  			"image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Robot_arm_icon.svg/2162px-Robot_arm_icon.svg.png",
	  			"alt_text": "devopsbot"
	  		}
	  	},
	  	{
	  		"type": "divider"
	  	},
	  	{
	  		"type": "section",
	  		"text": {
	  			"type": "mrkdwn",
	  			"text": "<https://github.com/moove-ai/{{.Build.Substitutions.REPO_NAME}}/commit/{{.Build.Substitutions.COMMIT_SHA}}|{{.Build.Substitutions.SHORT_SHA}}>"
	  		},
	  		"accessory": {
	  			"type": "button",
	  			"text": {
	  				"type": "plain_text",
	  				"text": "View Build History",
	  				"emoji": true
	  			},
	  			"value": "Build Logs",
	  			"url": "https://console.cloud.google.com/cloud-build/builds;region=global/{{.Build.Substitutions.BUILD_ID}}?project=${data.google_project.project.project_id}",
	  			"action_id": "button-action"
	  		}
	  	},
	  	{
	  		"type": "divider"
	  	}
	  ]
  EOT
}
