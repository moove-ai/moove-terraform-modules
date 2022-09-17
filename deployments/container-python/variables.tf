variable "project_id" {}
variable "build_branch" {}
variable "service_account" {}
variable "environment" {}
variable "build_name" {}
variable "build_description" {}
variable "git_repo" {}
variable "build_timeout" {
  type = string
  default = "600s"
}
variable "build_instance" {
  type = string
  description = "The GCE backend instance to build from. Valid options are: E2_HIGHCPU_8, E2_HIGHCPU_32, N1_HIGHCPU_8, N1_HIGHCPU_32"
  default = "UNSPECIFIED"
}

variable "tags" {
  type = list(string)
  description = "List of tags to add to the build"
  default = []
}
