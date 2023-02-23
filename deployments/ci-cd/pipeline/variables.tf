variable "cloudbuild_file" {
  type        = string
  default     = ""
  description = "Overrides the name default (cloudbuild.yaml) build file"
}

variable "github_repo" {
  type        = string
  description = "The github repo which holds the code to build"
}


variable "ci_branch_pattern" {
  type        = string
  default     = "^feature\\/.+|^hotfix\\/.+"
  description = "Overrides the default CI branch pattern"
}

variable "project_id" {
  type        = string
  default     = "moove-builds-a747"
  description = "description"
}

variable "build_name" {
  type        = string
  description = "The name of the build"
}

variable "deploy_name" {
  type        = string
  description = "The name of the deployment"
}

variable "cd_branch_pattern" {
  type        = string
  default     = "^release/.+"
  description = "The pattern which will trigger deployments"
}

variable "stage_name" {
  type        = string
  description = "The name of the stagnig step"
}

variable deploy_branch {
  type        = string
  default     = "main"
  description = "The branch that will trigger a production deploy when merged to"
}
