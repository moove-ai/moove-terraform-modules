resource "google_cloudbuild_trigger" "stage-file" {
  count           = var.stage_file != "" && var.stage_enabled == true ? 1 : 0
  name            = local.stage_name
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"

  included_files = local.stage_included_files
  ignored_files  = local.stage_ignored_files

  filename = var.stage_file
  tags     = local.stage_tags

  github {
    owner = "moove-ai"
    name  = var.github_repo
    pull_request {
      head_ref = var.stage_branch_pattern
      base_ref = "main"
    }

  }
}

resource "google_cloudbuild_trigger" "stage" {
  count           = var.stage_file == "" && var.stage_enabled == true ? 1 : 0
  name            = local.stage_name
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"

  included_files = local.stage_included_files
  ignored_files  = local.stage_ignored_files
  tags           = local.stage_tags

  github {
    owner = "moove-ai"
    name  = var.github_repo
    pull_request {
      branch = var.stage_branch_pattern
    }
  }

  substitutions = {
    _CLUSTER_PROJECT = var.cluster_project
    _CLUSTER_NAME    = var.cluster_name
    _CLUSTER_REGION  = var.cluster_region


  }

  build {
    logs_bucket = "gs://moove-build-logs"
    timeout     = var.stage_timeout
    images = [
      "gcr.io/$PROJECT_ID/$REPO_NAME:cache",
    ]

    available_secrets {
      secret_manager {
        env          = "GITHUB_TOKEN"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
      }
      secret_manager {
        env          = "DEVOPSBOT_PASSWORD"
        version_name = "projects/moove-secrets/secrets/argocd_devopsbot_password/versions/latest"
      }
      secret_manager {
        env          = "SLACK_HOOK"
        version_name = "projects/moove-secrets/secrets/cicd-slack-deploys-hook/versions/latest"
      }
    }

    step {
      id         = "get-release-version"
      name       = "maniator/gh"
      entrypoint = "sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        gh repo clone moove-ai/$REPO_NAME /workspace/repo -- --branch $BRANCH_NAME
        cd /workspace/repo
        echo $(git rev-parse --abbrev-ref HEAD |  tr -d -c 0-9.) > /workspace/version.txt
        echo $(git log -1 --pretty=%B) > /workspace/git_message.txt
        echo $(git log -1 --pretty=format:'%an') > /workspace/git_user.txt
        echo $(git log -1 --pretty=format:'%ae') > /workspace/git_email.txt
        EOF
      ]
    }

    step {
      id         = "clone-apps-repo"
      name       = "maniator/gh"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        gh repo clone moove-ai/k8s-apps /workspace/k8s-apps
        EOF
      ]
    }

    step {
      id         = "set-apps-permissions"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "/bin/bash"
      args = ["-c", <<-EOF
        touch /workspace/name.txt
        touch /workspace/regions.txt
        touch /workspace/deploy_version.txt
        touch /workspace/config
        chmod 0777 /workspace/name.txt
        chmod 0777 /workspace/regions.txt
        chmod 0777 /workspace/version.txt
        chmod 0777 /workspace/config
        chmod 0777 /workspace/k8s-apps/apps/staging.yaml
        EOF
      ]
    }

    step {
      id         = "check-for-deployments"
      name       = "mikefarah/yq"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        cd /workspace/k8s-apps
        yq .argocdApplications.$REPO_NAME.deployVersion apps/staging.yaml > /workspace/deploy_version.txt
        cat /workspace/deploy_version.txt
        if [[ $(cat /workspace/deploy_version.txt) != $(cat /workspace/version.txt) ]] && [[ $(cat /workspace/deploy_version.txt) != "null" ]]; then
          echo "Deployment in process."
          echo "Please finish release/$(cat /workspace/deploy_version.txt)"
          exit 1
        fi
        EOF
      ]
    }

    step {
      id         = "get-deployment-regions"
      name       = "mikefarah/yq"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        cd /workspace/k8s-apps
        yq '.global.spec.destination.deployServers[].region' apps/staging.yaml > /workspace/regions.txt
        cat /workspace/regions.txt
        EOF
      ]
    }

    step {
      id         = "get-argo-cluster-config"
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = ["-c", <<-EOF
        echo "PR NUMBER: $_PR_NUMBER"
        echo "HEAD BRANCH: $_HEAD_BRANCH"
        echo "BASE BRANCH: $_BASE_BRANCH"
        gcloud config set project $_CLUSTER_PROJECT
        gcloud container clusters get-credentials $_CLUSTER_NAME --region $_CLUSTER_REGION --project $_CLUSTER_PROJECT
        EOF
      ]
      env = [
        "KUBECONFIG=/kube_config/config",
        "USE_GKE_GCLOUD_AUTH_PLUGIN=True",
        "CLOUDSDK_CORE_PROJECT=$_CLUSTER_PROJECT"
      ]
      volumes {
        name = "kube-config"
        path = "/kube_config"
      }
    }

    step {
      id         = "cache"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "/bin/bash"
      args = ["-c", <<-EOF
        docker pull gcr.io/$PROJECT_ID/$REPO_NAME:cache || exit 0
        EOF
      ]
    }

    step {
      id         = "build-container"
      name       = "docker"
      entrypoint = "sh"
      args = ["-c", <<-EOF
        ${local.build_args}
      EOF
      ]
    }

    step {
      id         = "push"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "/bin/bash"
      args = ["-c", <<-EOF
        docker image push --all-tags gcr.io/$PROJECT_ID/$REPO_NAME
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
      id         = "mark-deployments"
      name       = "mikefarah/yq"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        cd /workspace/k8s-apps
        export _release_version=$(cat /workspace/version.txt)
        yq -i ".argocdApplications.$REPO_NAME.deployVersion = strenv(_release_version)" apps/staging.yaml
        EOF
      ]
    }

    step {
      id         = "configure-staging"
      name       = "mikefarah/yq"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        cd /workspace/k8s-apps
        export VERSION=v$(cat /workspace/version.txt)
        cd /workspace/k8s-apps
        export name=$(yq '.argocdApplications.$REPO_NAME.name' apps/staging.yaml)
        if [[ $$name == "null" ]]; then
          echo "Definition missing from k8s-apps/apps/staging.yaml"
          exit 1
        fi
        echo  $$name > /workspace/name.txt
        yq -i '.argocdApplications.$REPO_NAME.disable = false' apps/staging.yaml
        yq -i '.argocdApplications.$REPO_NAME.imageTag = strenv(VERSION)' apps/staging.yaml
        echo "Got name: $(cat /workspace/name.txt), version: $(cat /workspace/version.txt)"
        EOF
      ]
    }

    step {
      id         = "staging-deploy"
      name       = "maniator/gh"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        cd /workspace/k8s-apps
        git config user.name 'devopsbot'
        git config user.email 'devopsbot@moove.ai'
        git remote set-url origin https://devopsbot:$$GITHUB_TOKEN@github.com/moove-ai/k8s-apps.git
        git add apps/staging.yaml
        git commit -m "staging $REPO_NAME | version: $(cat /workspace/version.txt)"
        git push
        EOF
      ]
    }

    step {
      id         = "port-forward"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "/bin/bash"
      env        = ["KUBECONFIG=/kube_config/config"]
      args = ["-c", <<-EOF
        docker run --name network -itd --network-alias argocd-server.local \
          -e CLOUDSDK_COMPUTE_REGION="$_CLUSTER_REGION" \
          -e CLOUDSDK_CONTAINER_CLUSTER="$_CLUSTER_NAME" \
          -e CLOUDSDK_CORE_PROJECT="$_CLUSTER_PROJECT" \
          -p 8888:8888 \
          --network cloudbuild \
          gcr.io/cloud-builders/kubectl \
          port-forward -n argocd svc/argocd-server --address 0.0.0.0 8888:443
          docker logs -t network
        EOF
      ]
      volumes {
        name = "kube-config"
        path = "/kube_config"
      }
    }

    step {
      id         = "sync-app"
      name       = "argoproj/argocd"
      entrypoint = "/bin/bash"
      env        = ["KUBECONFIG=/kube_config/config"]
      secret_env = ["DEVOPSBOT_PASSWORD"]
      args = ["-c", <<-EOF
        echo "checking: $(cat /workspace/name.txt)"
        argocd --config=/workspace/config login --insecure argocd-server.local:8888 --username=devopsbot --password=$$DEVOPSBOT_PASSWORD
        argocd --config=/workspace/config app sync applications || exit 0
        echo "waiting for app to sync"
        sleep 10;
        echo "checking status"
        while [ $(argocd app --config=/workspace/config get applications-staging | grep 'Health Status' | awk '{ print $3 }') != "Healthy" ]; do
          argocd --config=/workspace/config app sync applications-staging
          sleep 10;
          echo "App Status: $(argocd app --config=/workspace/config get applications-staging | grep 'Health Status' | awk '{ print $3 }')"
        done
        for region in $(cat /workspace/regions.txt); do
          export app_name=$(cat /workspace/name.txt)-staging-$$region
          echo "Checking $$app_name"
          while [ $(argocd app --config=/workspace/config get $$app_name | grep 'Health Status' | awk '{ print $3 }') != "Healthy" ]; do
              argocd --config=/workspace/config app sync $$_app_name 
              sleep 10;
              echo "App Status: $(argocd app --config=/workspace/config get $$_app_name | grep 'Health Status' | awk '{ print $3 }')"
            done
          echo " $$app_name: $(argocd app --config=/workspace/config get $$_app_name | grep 'Health Status' | awk '{ print $3 }')"
          done
        EOF
      ]
      volumes {
        name = "kube-config"
        path = "/kube_config"
      }
    }

    step {
      id         = "send-slack"
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
          				"text": ":white_check_mark: Application Staged: $(cat /workspace/name.txt) | Version: $(cat /workspace/version.txt)"
          			}
          		},
          		{
          			"type": "divider"
          		},
          		{
          			"type": "section",
          			"text": {
          				"type": "mrkdwn",
          				"text": "*<https://deployments.moove.co.in/applications/argocd/applications-staging?view=tree&resource=|ArgoCD Staging Applications>*"
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

resource "google_cloudbuild_trigger" "stage-no-test" {
  count           = var.stage_file == "" && var.stage_enabled == false ? 1 : 0
  name            = local.stage_name
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"
  included_files  = local.stage_included_files
  ignored_files   = local.stage_ignored_files
  tags            = local.stage_tags

  github {
    owner = "moove-ai"
    name  = var.github_repo
    pull_request {
      branch = var.stage_branch_pattern
    }
  }

  build {
    logs_bucket = "gs://moove-build-logs"
    timeout     = var.build_timeout
    images = [
      "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA",
      "gcr.io/$PROJECT_ID/$REPO_NAME:cache",
    ]

    available_secrets {
      secret_manager {
        env          = "GITHUB_TOKEN"
        version_name = "projects/moove-secrets/secrets/ci-cd_github-token/versions/latest"
      }
      secret_manager {
        env          = "SLACK_HOOK"
        version_name = "projects/moove-secrets/secrets/cicd-slack-deploys-hook/versions/latest"
      }
    }


    dynamic "options" {
      for_each = var.build_instance != "" ? [0] : []
      content {
        machine_type = var.build_instance
      }
    }

    step {
      id         = "get-release-version"
      name       = "maniator/gh"
      entrypoint = "sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        gh repo clone moove-ai/$REPO_NAME /workspace/repo -- --branch $BRANCH_NAME
        cd /workspace/repo
        echo $(git rev-parse --abbrev-ref HEAD |  tr -d -c 0-9.) > /workspace/version.txt
        echo $(git log -1 --pretty=%B) > /workspace/git_message.txt
        echo $(git log -1 --pretty=format:'%an') > /workspace/git_user.txt
        echo $(git log -1 --pretty=format:'%ae') > /workspace/git_email.txt
        EOF
      ]
    }

    step {
      id         = "cache"
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
        docker build \
          -t gcr.io/$PROJECT_ID/$REPO_NAME:cache \
          -t gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA \
          -t gcr.io/$PROJECT_ID/$REPO_NAME:v$(cat /workspace/version.txt) \
          --cache-from gcr.io/$PROJECT_ID/$REPO_NAME:cache \
          .
      EOF
      ]
    }

    dynamic "step" {
      for_each = var.unit_test_enabled == true ? [0] : []
      content {
        id         = "unit-tests"
        wait_for   = ["build-container"]
        name       = "docker"
        entrypoint = "sh"
        args = ["-c", <<-EOF
          ${local.unit_test_args}
        EOF
        ]
      }
    }

    step {
      id         = "push"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "bash"
      args = ["-c", <<-EOF
        docker image push --all-tags gcr.io/$PROJECT_ID/$REPO_NAME
        echo 'pushed images'
      EOF
      ]
    }

    step {
      id         = "send-slack"
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
          				"text": ":white_check_mark: Release Built: $REPO_NAME | Version: $(cat /workspace/version.txt)"
          			}
          		},
          		{
          			"type": "divider"
          		},
          		{
          			"type": "section",
          			"text": {
          				"type": "mrkdwn",
          				"text": "*<https://deployments.moove.co.in/applications/argocd/applications?view=tree&resource=|ArgoCD Applications>*"
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
