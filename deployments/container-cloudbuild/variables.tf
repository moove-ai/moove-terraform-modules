variable "project_id" {
  type        = string
  description = "The project to deploy this build to"
}

variable "location" {
  type        = string
  description = "The region this trigger is deployed to"
  default     = "global"
}

variable "git_repo" {
  type        = string
  description = "The Git Repo holding the cloudbuild file"
}

variable "build_branch" {
  type        = string
  description = "The build branch to use for this build"
  default     = "main"
}

variable "environment" {
  type        = string
  description = "The environment that this build is running in"
}

variable "cloudbuild_filename" {
  type        = string
  description = "The path and name of the cloudbuild file"
  default     = "cloudbuild.yaml"
}

variable "build_name" {
  type        = string
  description = "The name of the build"
}

variable "build_description" {
  type        = string
  description = "The description."
}

variable "service_account" {
  type        = string
  description = "The service account running the build"
}

variable "tags" {
  type        = list(string)
  description = "List of tags to add to the build"
  default     = []
}

variable "included_files" {
  type        = list(string)
  description = "List of files which will trigger the build if changed"

}

variable "ignored_files" {
  type        = list(string)
  description = "List of files to exclude for the build trigger."
  default     = []
}

variable "enable_cache" {
  type        = string
  description = "If set to true, this build will use existing build cache"
}
