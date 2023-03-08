resource "google_cloudbuild_trigger" "deploy-file" {
  count           = var.deploy_file != "" ? 1 : 0
  name            = local.deploy_name
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"

  included_files = local.deploy_included_files
  ignored_files  = local.deploy_ignored_files

  filename = var.deploy_file
  tags     = local.deploy_tags

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.deploy_branch_pattern
    }
  }
}

resource "google_cloudbuild_trigger" "deploy" {
  count           = var.deploy_file != "" ? 0 : 1
  name            = local.deploy_name
  project         = var.project_id
  service_account = "projects/${var.project_id}/serviceAccounts/deployer@${var.project_id}.iam.gserviceaccount.com"

  included_files = local.deploy_included_files
  ignored_files  = local.deploy_ignored_files
  tags           = local.deploy_tags

  github {
    owner = "moove-ai"
    name  = var.github_repo
    push {
      branch = var.deploy_branch_pattern
    }
  }

  substitutions = {
    _CLUSTER_PROJECT = var.cluster_project
    _CLUSTER_NAME    = var.cluster_name
    _CLUSTER_REGION  = var.cluster_region

  }

  build {
    logs_bucket = "gs://moove-build-logs"
    timeout     = var.deploy_timeout

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
      id         = "get-argo-cluster-config"
      name       = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = ["-c", <<-EOF
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
      id         = "get-git-info"
      name       = "maniator/gh"
      entrypoint = "sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        gh repo clone moove-ai/$REPO_NAME /workspace/repo -- --branch $BRANCH_NAME
        cd /workspace/repo
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
      id         = "set-permissions"
      name       = "gcr.io/cloud-builders/docker"
      entrypoint = "/bin/bash"
      args = ["-c", <<-EOF
        touch /workspace/name.txt
        touch /workspace/config
        chmod 0777 /workspace/name.txt
        chmod 0777 /workspace/config
        chmod 0777 /workspace/k8s-apps/apps/production.yaml
        chmod 0777 /workspace/k8s-apps/apps/staging.yaml
        EOF
      ]
    }

    step {
      id         = "configure-production"
      name       = "mikefarah/yq"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        cd /workspace/k8s-apps
        cd /workspace/k8s-apps
        echo $(yq '.argocdApplications.$REPO_NAME.name' apps/production.yaml) > /workspace/name.txt
        echo $(yq .argocdApplications.$REPO_NAME.imageTag apps/staging.yaml) > /workspace/version.txt
        export VERSION=v$(cat /workspace/version.txt)
        yq -i '.argocdApplications.$REPO_NAME.imageTag = strenv(VERSION)' apps/production.yaml
        EOF
      ]
    }

    step {
      id         = "disable-staging"
      name       = "mikefarah/yq"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        cd /workspace/k8s-apps
        export VERSION=v$(cat /workspace/version.txt)
        cd /workspace/k8s-apps
        yq -i '.argocdApplications.$REPO_NAME.disable = true' apps/staging.yaml
        EOF
      ]
    }

    step {
      id         = "git-tag"
      name       = "maniator/gh"
      entrypoint = "sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        gh repo clone moove-ai/$REPO_NAME /workspace/repo -- --branch $BRANCH_NAME
        cd /workspace/repo
        echo $(git log -1 --pretty=%B) > /workspace/git_message.txt
        echo $(git log -1 --pretty=format:'%an') > /workspace/git_user.txt
        echo $(git log -1 --pretty=format:'%ae') > /workspace/git_email.txt
        EOF
      ]
    }

    step {
      id         = "deploy"
      name       = "maniator/gh"
      entrypoint = "/bin/sh"
      secret_env = ["GITHUB_TOKEN"]
      args = ["-c", <<-EOF
        cd /workspace/k8s-apps
        git config user.name 'devopsbot'
        git config user.email 'devopsbot@moove.ai'
        git remote set-url origin https://devopsbot:$$GITHUB_TOKEN@github.com/moove-ai/k8s-apps.git
        git add apps/production.yaml
        git add apps/staging.yaml
        git commit -m "Deploying: $(cat /workspace/name.txt) | version: $(cat /workspace/version.txt)"
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
        argocd --config=/workspace/config app sync applications-staging || exit 0
        echo "waiting for app to sync"
        sleep 10;
        echo "checking status"
        while [ $(argocd app --config=/workspace/config get applications | grep 'Health Status' | awk '{ print $3 }') != "Healthy" ]; do
          argocd --config=/workspace/config app sync applications
          sleep 10;
          echo "App Status: $(argocd app --config=/workspace/config get applications | grep 'Health Status' | awk '{ print $3 }')"
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
        cat << EOF > payload.json
        {
          "blocks": [
            {
              "type": "section",
              "text": {
                "type": "mrkdwn",
          				"text": ":white_check_mark: Application Deployed: `$(cat /workspace/name.txt) Version: $(cat /workspace/version.txt)`\n*<https://deployments.moove.co.in/applications/argocd/applications?view=tree&resource=|ArgoCD Applications>*"
              }
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
