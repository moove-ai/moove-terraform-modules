variable "project_id" {
  type = string
}

variable "build_branch" {
  type = string
  default = "main"
}

variable "service_account" {
  type = string
}

variable "environment" {
  type = string
}

variable "build_name" {
  type = string
}

variable "build_description" {
  type = string
}

variable "git_repo" {
  type = string
}

variable "build_timeout" {
  type    = string
  default = "600s"
}

variable "build_instance" {
  type        = string
  description = "The GCE backend instance to build from. Valid options are: E2_HIGHCPU_8, E2_HIGHCPU_32, N1_HIGHCPU_8, N1_HIGHCPU_32"
  default     = "UNSPECIFIED"
}

variable "tags" {
  type        = list(string)
  description = "List of tags to add to the build"
  default     = []
}

variable "included_files" {
  type        = list(string)
  description = "list of files that will trigger a build when modified"
}

variable "ignored_files" {
  type        = list(string)
  description = "list of files that will trigger a build when modified"
  default     = []
}
