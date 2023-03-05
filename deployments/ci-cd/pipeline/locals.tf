locals {
  build_file  = var.build_file != "" ? var.build_file : "build.yaml"
  stage_file  = var.stage_file != "" ? var.stage_file : "stage.yaml"
  deploy_file = var.deploy_file != "" ? var.deploy_file : "deploy.yaml"

  build_name  = var.build_name != "" ? var.build_name : "build-k8s-app-${var.github_repo}"
  stage_name  = var.stage_name != "" ? var.stage_name : "stage-k8s-app-${var.github_repo}"
  deploy_name = var.deploy_name != "" ? var.deploy_name : "deploy-k8s-app-${var.github_repo}"

  build_included_files = var.build_included_files != [] ? var.build_included_files : ["**"]
  stage_included_files = var.stage_included_files != [] ? var.stage_included_files : ["**"]
  deploy_included_files = var.deploy_included_files != [] ? var.deploy_included_files : ["**"]

  build_ignored_files = var.build_ignored_files != [] ? var.build_ignored_files : ["helm/**", "deploy.yaml", "stage.yaml"]
  stage_ignored_files = var.stage_ignored_files != [] ? var.stage_ignored_files : ["deploy.yaml", "build.yaml"]
  deploy_ignored_files = var.deploy_ignored_files != [] ? var.deploy_ignored_files : ["build.yaml", "stage.yaml"]

  default_build_args  = ["-t", "gcr.io/$PROJECT_ID/$REPO_NAME:cache", "-t", "gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA", "."]
  build_args          = var.build_args != [] ? concat(["build"], var.build_args) : concat(["build"], local.default_build_args) :

  test_entrypoint     = var.test_entrypoint != "" ? var.test_entrypoint : "python"
  test_args           = var.test_args != [] ? var.test_args : "-m unittest discover -s tests -t ."

}

