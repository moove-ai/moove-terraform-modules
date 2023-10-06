variable "build_name" {
  type        = string
  description = "The name of the Cloud Build trigger"
}

variable "build_project_id" {
  type        = string
  description = "The Google Cloud project ID"
  default = "moove-build"
}

variable "build_included_files" {
  type        = list(string)
  description = "A list of file patterns to be included in the build trigger"
  default     = []
}

variable "build_ignored_files" {
  type        = list(string)
  description = "A list of file patterns to be ignored by the build trigger"
  default     = []
}

variable "build_tags" {
  type        = list(string)
  description = "A list of tags to apply to the build trigger"
  default     = []
}

variable "disable_trigger" {
  type        = bool
  description = "Whether to disable the build trigger"
  default     = false
}

variable "build_file" {
  type        = string
  description = "The path to the build file"
}

variable "github_repo" {
  type        = string
  description = "The name of the GitHub repository"
}

variable "build_branch_pattern" {
  type        = string
  description = "The pattern to match against branch names"
  default     = "^master$"
}

variable "addiotnal_build_substitions" {
  type        = map(string)
  description = "Additional substitutions to add to the build configuration"
  default     = {}
}

