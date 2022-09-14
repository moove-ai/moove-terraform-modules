locals {
  deploy_http_template = <<EOT
    gcloud functions deploy ${var.function_name} --region=${var.function_region} \
      --source=${var.function_source} \
      --trigger-http \
      --runtime=${var.function_runtime} \
      --entry-point=${var.function_entrypoint} \
      --memory=${var.function_memory} \
      --region=${var.function_region} \
      --project=${var.function_project_id} \
      --vpc-connector ${var.function_vpc_connector} \
      --update-labels=function=${var.function_label},git-repo=$REPO_NAME
  EOT

  deploy_pubsub_template = <<EOT
    gcloud functions deploy ${var.function_name} --region=${var.function_region} \
      --source=${var.function_source} \
      --trigger-topic ${var.function_trigger_topic} \
      --runtime=${var.function_runtime} \
      --entry-point=${var.function_entrypoint} \
      --memory=${var.function_memory} \
      --region=${var.function_region} \
      --project=${var.function_project_id} \
      --vpc-connector ${var.function_vpc_connector} \
      --update-labels=function=${var.function_label},git-repo=$REPO_NAME
  EOT

  grafana_annotation = <<EOT
    export CURRENT_TIME=$(date +%s%3N)
    export GIT_MESSAGE=$(git log -1 --pretty=%B)
    cat << EOF > grafana.json
    {
      "time": $$CURRENT_TIME,
      "timeEnd": $$CURRENT_TIME,
      "tags": [
        "cf",
        "$_ENVIRONMENT",
        "$REPO_NAME",
        "${var.function_label}"
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
            "text": "Cloud Function Deployed:\n*<https://console.cloud.google.com/functions/details/$_FUNCTION_REGION/$_FUNCTION_NAME?env=gen1&project=$_FUNCTION_PROJECT_ID|$_FUNCTION_NAME - $_FUNCTION_PROJECT_ID>*"
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
