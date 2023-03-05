variable "project_id" {
  type        = string
  default     = "moove-builds-a747"
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

variable "stage_branch_pattern" {
  type        = string
  default     = "^release/.+"
  description = "The pattern which will trigger deployments"
}

variable "deploy_branch_pattern" {
  type        = string
  default     = "^main$"
  description = "The branch that will trigger a production deploy when merged to"
}

variable "build_name" {
  type        = string
  default     = ""
  description = "The name of the build"
}

variable "stage_name" {
  type        = string
  default     = ""
  description = "The name of the build"
}

variable "deploy_name" {
  type        = string
  default     = ""
  description = "The name of the deployment"
}

variable build_file {
  type        = string
  default     = ""
  description = "Optional. Overrides the default `build.yaml` file location"
}

variable stage_file {
  type        = string
  default     = ""
  description = "Optional. Overrides the default `stage.yaml` file location"
}

variable deploy_file {
  type        = string
  default     = ""
  description = "Optional. Overrides the default `deploy.yaml` file location"
}

variable build_included_files {
  type        = list(string)
  default     = []
  description = "List of files or patterns to trigger the build step"
}

variable stage_included_files {
  type        = list(string)
  default     = []
  description = "List of files or patterns to trigger the stage step"
}

variable deploy_included_files {
  type        = list(string)
  default     = []
  description = "List of files or patterns to trigger the deploy step"
}

variable build_ignored_files {
  type        = list(string)
  default     = []
  description = "List of files which will NOT trigger a build"
}

variable stage_ignored_files {
  type        = list(string)
  default     = []
  description = "List of files which will NOT trigger a stage"
}

variable deploy_ignored_files {
  type        = list(string)
  default     = []
  description = "List of files which will NOT trigger a deploy"
}

variable region {
  type        = string
  description = "The region this app is deploying to"
}

variable environment {
  type        = string
  description = "The environment this app is deploying to"
}

variable cluster_project {
  type        = string
  description = "The project where the GKE cluster running this app is running"
}



# BUILD VARIABLES
variable build_timeout {
  type        = string
  default     = "300s"
  description = "description"
}

variable build_args {
  type        = string
  default     = []
  description = "description"
}
