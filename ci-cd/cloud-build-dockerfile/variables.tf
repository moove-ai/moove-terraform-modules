variable "build_name" {
  description = "The name of the Cloud Build trigger."
  type        = string
}

variable "location" {
  description = "The location where the Cloud Build trigger will be created."
  type        = string
  default     = "global"
}

variable "project_id" {
  description = "The GCP project ID where resources will be applied."
  type        = string
  default     = "moove-build"
}

variable "build_included_files" {
  description = "List of file glob patterns to include in the build process."
  type        = list(string)
  default     = ["**"]
}

variable "build_ignored_files" {
  description = "List of file glob patterns to ignore in the build process."
  type        = list(string)
  default     = ["README.md"]
}

variable "build_tags" {
  description = "Tags for identifying and organizing build triggers."
  type        = list(string)
  default     = []
}

variable "disable_trigger" {
  description = "Boolean to determine if the build trigger is disabled."
  type        = bool
  default     = false
}

variable "github_repo" {
  description = "The name of the GitHub repository."
  type        = string
}

variable "build_branch_pattern" {
  description = "The pattern to match against branch names to trigger a build."
  type        = string
}

variable "image_name" {
  description = "Name of the Docker image to build."
  type        = string
}

variable "image_tag" {
  description = "Tag to apply to the Docker image."
  type        = string
}
