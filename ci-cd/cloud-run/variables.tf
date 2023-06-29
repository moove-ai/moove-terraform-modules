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

variable "stage_branch_pattern" {
  type        = string
  default     = "^main$"
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

# BUILD VARIABLES
variable "build_timeout" {
  type        = string
  default     = "300s"
  description = "How long should this build run before automatically failing"
}

variable "build_instance" {
  type        = string
  default     = ""
  description = "The machine type to use for this build"
}

variable "build_args" {
  type        = string
  default     = ""
  description = "Full docker command to pass to the build"
}

variable "unit_test_entrypoint" {
  type        = string
  default     = ""
  description = "Optional. Defaults to `python`. The entrypoint used in the testing step"
}

variable "unit_test_args" {
  type        = string
  default     = ""
  description = "Optional. Defaults to `-m unittest discover -s tests -t .`. The entrypoint used in the testing step"
}

variable "unit_test_enabled" {
  type        = bool
  default     = true
  description = "Enables or disables unit tests for this build"
}
