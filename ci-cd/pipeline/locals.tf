locals {
  build_name  = var.build_name != "" ? var.build_name : "build-k8s-app-${var.github_repo}"
  stage_name  = var.stage_name != "" ? var.stage_name : "stage-k8s-app-${var.github_repo}"
  deploy_name = var.deploy_name != "" ? var.deploy_name : "deploy-k8s-app-${var.github_repo}"

  build_included_files  = var.build_included_files != [] ? var.build_included_files : ["**"]
  stage_included_files  = var.stage_included_files != [] ? var.stage_included_files : ["**"]
  deploy_included_files = var.deploy_included_files != [] ? var.deploy_included_files : ["**"]

  build_ignored_files  = var.build_ignored_files != [] ? var.build_ignored_files : ["helm/**", "deploy.yaml", "stage.yaml"]
  stage_ignored_files  = var.stage_ignored_files != [] ? var.stage_ignored_files : ["deploy.yaml", "build.yaml"]
  deploy_ignored_files = var.deploy_ignored_files != [] ? var.deploy_ignored_files : ["build.yaml", "stage.yaml"]

  default_build_args = <<-EOF
  docker build \
    -t gcr.io/$PROJECT_ID/$REPO_NAME:cache \
    -t gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA \
    --cache-from gcr.io/$PROJECT_ID/$REPO_NAME:cache \
    .
  EOF

  default_stage_build_args = <<-EOF
  docker build \
    -t gcr.io/$PROJECT_ID/$REPO_NAME:cache \
    -t gcr.io/$PROJECT_ID/$REPO_NAME:v$(cat /workspace/version.txt) \
    -t gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA \
    --cache-from gcr.io/$PROJECT_ID/$REPO_NAME:cache \
    .
  EOF
  build_args               = var.build_args != "" ? var.build_args : local.default_build_args
  stage_build_args         = var.stage_build_args != "" ? var.stage_build_args : local.default_stage_build_args

  default_test_args = <<-EOF
  docker run  \
    --entrypoint python \
    gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA \
    -m unittest discover -s tests -t .
  EOF

  unit_test_args = var.unit_test_args != "" ? var.unit_test_args : local.default_test_args


  build_tags  = [var.github_repo, "build"]
  stage_tags  = [var.github_repo, "staging", "stage"]
  deploy_tags = [var.github_repo, "deploy"]
}
