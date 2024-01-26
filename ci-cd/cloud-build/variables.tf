variable "build_name" {
  description = "Name of the Cloud Build trigger."
  type        = string
}

variable "project_id" {
  description = "ID of the Google Cloud project."
  default     = "moove-build"
  type        = string
}

variable "build_included_files" {
  description = "List of files to include in the build."
  type        = list(string)
}

variable "build_ignored_files" {
  description = "List of files to ignore in the build."
  type        = list(string)
  default     = []
}

variable "build_tags" {
  description = "List of tags to associate with the build trigger."
  type        = list(string)
  default     = []
}

variable "disable_trigger" {
  description = "Whether to disable the trigger (true or false)."
  type        = bool
  default     = false
}

variable "build_file" {
  description = "Name of the build configuration file (e.g., cloudbuild.yaml)."
  type        = string
  default     = "cloudbuild.yaml"
}

variable "github_repo" {
  description = "Name of the GitHub repository."
  type        = string
}

variable "build_branch_pattern" {
  description = "Branch pattern to trigger the build on GitHub pushes."
  type        = string
}

variable "substitutions" {
  type        = map(string)
  description = "values to substitute into the build config file"
  default     = {}
}

variable "trigger_type" {
  description = "Type of trigger: push or pull_request"
  type        = string
}
