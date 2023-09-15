variable "project_id" {
  type        = string
  default     = "moove-build"
  description = "description"
}

#variable "cloudbuild_file" {
#  type        = string
#  default     = ""
#  description = "Overrides the name default (cloudbuild.yaml) build file"
#}

variable "github_repo" {
  type        = string
  description = "The github repo which holds the code to build"
}

variable "build_branch_pattern" {
  type        = string
  default     = "^feature/.+|^feat/.+|^hotfix/.+"
  description = "Overrides the default CI branch pattern"
}

variable "build_name" {
  type        = string
  default     = ""
  description = "The name of the build"
}

variable "build_file" {
  type        = string
  default     = ""
  description = "Optional. Overrides the default `build.yaml` file location"
}

variable "build_included_files" {
  type        = list(string)
  default     = []
  description = "List of files or patterns to trigger the build step"
}

variable "build_ignored_files" {
  type        = list(string)
  default     = []
  description = "List of files which will NOT trigger a build"
}

variable "environment" {
  type        = string
  description = "The environment this app is deploying to"
}

variable "deploy_region" {
  type        = string
  description = "The region for the Cloud Function"
}

variable "deployer_account_id" {
  type        = string
  description = "The service account that runs deploys"
  default     = "deployer"
}

variable "deployer_project_id" {
  type        = string
  description = "The service account that runs deploys"
  default     = "moove-build"
}

variable "location" {
  type        = string
  description = "The location of the Cloud Build trigger"
  default     = "global"
}
  