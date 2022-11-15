# Common
variable "project_id" {
  type        = string
  description = "The project id the trigger should be deployed to"
}

variable "environment" {
  type        = string
  description = "The environment the CD applications are being deployed to"
}

variable "app_name" {
  type        = string
  description = "The name of the app to be deployed. This needs to be the same name"
}

variable "region" {
  type        = string
  description = "The region the app is being deployed to"
}


variable "type" {
  type        = string
  description = "Is this an application, or cluster operations. Valid values: apps, ops"
  default     = "apps"
}

variable "build_args" {
  type        = list(string)
  description = "List of Arguments to append to the docker build"
  default     = []
}

# Deployment
variable "namespace" {
  type        = string
  description = "The namespace this app should be deployed to"
}

variable "tag_path" {
  type        = string
  description = <<-EOT
    The path holding the image tag value in the k8s-deployment repo.
    Stored in: releases/$TYPE/$APP_NAME/values/$ENVIRONEMNT.yaml.
    Defaults to '.image.tag'.
    Path must begin with '.' (.frontend.image.tag, .init.image.tag, etc)
    EOT
  default     = ".image.tag"
}

variable "ci_cd_branch" {
  type        = string
  description = "The branch on k8s-deployments the CD process should run off of"
  default     = "main"
}

variable "gke_cluster" {
  type        = string
  description = "The name of the GKE cluster to deploy to"
  default     = ""
}

variable "github_ssh_key_name" {
  type        = string
  description = "The name of the secret holding the ssh key with access to the k8s-deployments repo. Secret located in the moove-secrets project"
  default     = "ci-cd_github-ssh-key"
}

variable "helmfile_image" {
  type        = string
  default     = "quay.io/roboll/helmfile"
  description = "The helmfile image to use"
}

variable "helmfile_image_tag" {
  type        = string
  default     = "v0.143.0-stable-slim"
  description = "The helmfile image tag to use"
}

variable "prefix" {
  type        = string
  description = "The prefix to apply to the deployment name"
  default     = "deploy-k8s"
}

variable "deployment_repo" {
  type        = string
  description = "The name of the repo being used as the source of truth for deployments"
  default     = "k8s-deployments"
}

variable "revision_history" {
  type        = string
  description = "The number of revions to keep in the ArgoCD History. Defaults to 3"
  default     = "3"
}

variable "app_path" {
  type        = string
  description = "The folder name the app is stored in."
  default     = ""
}

variable "target_revision" {
  type        = string
  description = "The git revision to trigger deployments on"
  default     = "HEAD"
}

variable "prune" {
  type        = string
  description = "If true, deletes resouces when the app is removed from ArgoCD"
  default     = "true"
}

variable "self_heal" {
  type        = string
  description = "If true, the application will automatically fix backend resources that are removed/changed"
  default     = "true"
}

variable "create_namespace" {
  type        = string
  description = "If true, creates the namespace if it does not already exist."
  default     = "true"
}

variable "respect_ignore_differences" {
  type        = string
  description = "If true, will ignore changes that are requested to be ignored."
  default     = "true"
}

variable "deploy" {
  type        = bool
  description = "Set to false to disable the deployment step. Useful for builds where there are multiple images on the same deployment"
  default     = true
}

variable "ci_cd_name_override" {
  type        = string
  default     = ""
  description = "Overrides the app_name value. Useful if you have two apps that update the same chart, like the scoring-frontend & scoring-backend"
}

variable "create_argo_app" {
  type        = bool
  description = "Set to false to skip the creation of the ArgoCD App. Useful for two deployments that use the same chart. See: scoring-frontend, scoring-backend"
  default     = true
}

variable "argo_app_namespace" {
  type        = string
  default     = "default"
  description = "The namespace where the argocd Application object should be created in."
}

variable "deployment_name" {
  type        = string
  default     = ""
  description = "Optional. Overrides the name of the deployment. Appends the name onto the end of: k8s-deploy-app|op-$deployment_name"
}

# Build
variable "build_tags" {
  type        = list(string)
  description = "Tags to append to app builds"
  default     = []
}

variable "build_files" {
  type        = list(string)
  description = "List of files that will trigger a build."
  default     = ["main.py", "requirements.txt", "Dockerfile"]
}

variable "build_ignored_files" {
  type        = list(string)
  description = "List of files that will be ignored if they are changed."
  default     = []
}

variable "build_repo" {
  type        = string
  description = "The repo that holds the code to be deployed."
  default     = ""
}

variable "build_branch" {
  type        = string
  description = "The branch of the repo to build."
  default     = "main"
}

variable "build_instance" {
  type        = string
  description = "The GCE backend instance to build from. Valid options are: E2_HIGHCPU_8, E2_HIGHCPU_32, N1_HIGHCPU_8, N1_HIGHCPU_32"
  default     = ""
}

variable "build_timeout" {
  type        = string
  description = "How long should the build wait before timing out."
  default     = "600s"
}

variable "build" {
  type        = bool
  description = "Set to false to disable the build step. Useful for helmcharts which do not require a custom image"
  default     = true
}

variable "deploy_included_files" {
  type        = list(string)
  default     = []
  description = "List of files which will trigger an ArgoCD Deployment if changed."
}
