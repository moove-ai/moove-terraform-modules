variable "project_id" {
  type = string
  description = "The project id the trigger should be deployed to"
}

variable "app_name" {
  type = string
  description = "The name of the app to be deployed. This needs to be the same name"
}

variable "service_account" {
  type = string
  description = "The service account running the CD process"
}

variable "ci_cd_branch" {
  type = string
  description = "The branch on k8s-deployments the CD process should run off of"
  default = "main"
}

variable "environment" {
  type = string
  description = "The environment the CD applications are being deployed to"
}

variable "github_ssh_key_name" {
  type = string
  description = "The name of the secret holding the ssh key with access to the k8s-deployments repo. Secret located in the moove-secrets project"
  default = "ci-cd_github-ssh-key"
}

variable "gke_cluster" {
  type = string
  description = "The name of the GKE cluster to deploy to"
}

variable "helmfile_image" {
  type = string
  default = "quay.io/roboll/helmfile"
  description = "The helmfile image to use"
}

variable "helmfile_image_tag" {
  type = string
  default = "v0.143.0-stable-slim"
  description = "The helmfile image tag to use"
}

variable "app_output_dir" {
  default = "apps/"
}

variable "prefix" {
  type = string
  description = "The prefix to apply to the deployment name"
  default = "deploy-k8s"
}

variable "tags" {
  type = list(string)
  description = "Tags to append to app builds"
  default = []
}

variable "region" {
  type = string
  description = "The region the app is being deployed to"
}

variable "deployment_repo" {
  type = string
  description = "The name of the repo being used as the source of truth for deployments"
  default = "k8s-deployments"
}

variable "namespace" {
  type = string
  description = "The namespace this app should be deployed to"
}

variable "revision_history" {
  type = string
  description = "The number of revions to keep in the ArgoCD History. Defaults to 3"
  default = "3"
}

variable "app_path" {
  type = string
  description = "The folder name the app is stored in."
}

variable "target_revision" {
  type = string
  description = "The git revision to trigger deployments on"
  default = "HEAD"
}

variable "prune" {
  type = string
  description = "If true, deletes resouces when the app is removed from ArgoCD"
  default = "true"
}

variable "self_heal" {
  type = string
  description = "If true, the application will automatically fix backend resources that are removed/changed"
  default = "true"
}

variable "create_namespace" {
  type = string
  description = "If true, creates the namespace if it does not already exist."
  default = "true"
}

variable "respect_ignore_differences" {
  type = string
  description = "If true, will ignore changes that are requested to be ignored."
  default = "true"
}

variable "type" {
  type = string  
  description = "Is this an application, or cluster operations. Valid values: apps, ops"
}
