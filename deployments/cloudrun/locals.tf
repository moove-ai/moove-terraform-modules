locals {
  cloudrun_deploy = <<EOT
    gcloud run deploy ${var.service_name} --image gcr.io/$PROJECT_ID/${var.repo_name}:$COMMIT_SHA \
      --region ${var.region} --service-account ${var.service_account} \
      --vpc-connector projects/${var.environment == "mgmt" ? "moove-systems" : "${var.network_project}"}/locations/${var.region}/connectors/${var.environment}-${var.region} \
      --vpc-egress private-ranges-only ${var.cpu_throttling_flag} --description '${var.service_description}' \
      --update-labels environment=${var.environment}
  EOT

  grafana_annotation = <<EOT
    export CURRENT_TIME=$(date +%s%3N)
    export GIT_MESSAGE=$(git log -1 --pretty=%B)
    cat << EOF > grafana.json
    {
      "time": $$CURRENT_TIME,
      "timeEnd": $$CURRENT_TIME,
      "tags": [
        "cr",
        "cloudrun",
        "$_ENVIRONMENT",
        "$REPO_NAME",
      ],
      "text": "$REPO_NAME:$SHORT_SHA - $$GIT_MESSAGE"
    }
    EOF


    curl -XPOST https://grafana.moove.ai/api/annotations \
      -H "Authorization: Bearer $$GRAFANA_API_KEY" \
      -H "Content-Type: application/json" \
      --data @grafana.json
  EOT

  slack_message = <<EOT
    export GIT_MESSAGE=$(git log -1 --pretty=%B)
    export GIT_USER=$(git log -1 --pretty=format:'%an')
    export GIT_EMAIL=$(git log -1 --pretty=format:'%ae')
    cat << EOF > payload.json
    {
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Cloud Run Service:\n*<https://console.cloud.google.com/run/detail/${var.region}/${var.service_name}/metrics?project=${var.project_id}|${var.service_name} - ${var.project_id}>*"
          }
        },
        {
          "type": "section",
          "fields": [
            {
              "type": "mrkdwn",
              "text": "*User:*\n$$GIT_USER"
            },
            {
              "type": "mrkdwn",
              "text": "*Email:*\n$$GIT_EMAIL"
            },
            {
              "type": "mrkdwn",
              "text": "*Message:*\n$$GIT_MESSAGE"
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
}
