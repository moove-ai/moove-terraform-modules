variable "project_id" {
  type        = string
  default     = "moove-build"
  description = "description"
}

variable "cloudbuild_file" {
  type        = string
  default     = ""
  description = "Overrides the name default (cloudbuild.yaml) build file"
}

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

variable "deploy_region" {
  type        = string
  description = "The region for the Cloud Deploy pipeline"
}

variable "deploy_name" {
  type        = string
  description = "The name of the Cloud Deploy pipeline"
}

variable "deploy_description" {
  type        = string
  description = "The description of the Cloud Deploy pipeline"
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

variable "pipeline_targets" {
  type = map(list(object({
    name            = string
    project_id      = string
    description     = string
    service_account = string
    deploy_project  = string
    deploy_region   = string
  })))
  default = {}
}

variable "auto_build" {
  type        = bool
  default     = true
  description = "Set to true to enable automatic builds. Set to false to enable manual builds."
}

variable "build_tags" {
  type        = list(string)
  default     = []
  description = "List of tags to apply to the build"
}

variable "build_additional_substitutions" {
  type        = map(string)
  description = "Additional substitiions to pass to the cloudbuild file located in the git repo"
  default     = {}
}

variable "disable_trigger" {
  type        = bool
  description = "Set to true to disable the build trigger"
  default     = false
}
