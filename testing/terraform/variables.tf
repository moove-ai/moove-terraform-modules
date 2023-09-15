variable "project_id" {
  type = string
  description = "The project ID this automated test will be deployed to."
}

variable "build_tags" {
  type        = list(string)
  description = "Tags to append to app builds"
  default     = []
}

variable "build_files" {
  type        = list(string)
  description = "List of files that will trigger a build."
  default     = ["main.py", "requirements.txt", "Dockerfile"]
}

variable "build_ignored_files" {
  type        = list(string)
  description = "List of files that will be ignored if they are changed."
  default     = []
}

variable "build_repo" {
  type        = string
  description = "The repo that holds the code to be deployed."
  default     = "moove-terraform-tests"
}

variable "build_branch" {
  type        = string
  description = "The branch of the repo to build."
  default     = "main"
}

variable "build_timeout" {
  type        = string
  description = "How long should the build wait before timing out."
  default     = "600s"
}

variable "app_name" {
  type        = string
  description = "The name of the app to be deployed. This needs to be the same name"
  default = "moove-terraform-tests"
}

variable "build_instance" {
  type        = string
  description = "The GCE backend instance to build from. Valid options are: E2_HIGHCPU_8, E2_HIGHCPU_32, N1_HIGHCPU_8, N1_HIGHCPU_32"
  default     = ""
}
 #

variable "deploy_tags" {
  type        = list(string)
  description = "Tags to append to app deploys"
  default     = []
}

variable "deploy_files" {
  type        = list(string)
  description = "List of files that will trigger a deploy."
  default     = ["main.py", "requirements.txt", "Dockerfile"]
}

variable "deploy_ignored_files" {
  type        = list(string)
  description = "List of files that will be ignored if they are changed."
  default     = []
}

variable "test_repo" {
  type        = string
  description = "The repo that will be tested"
  default     = "moove-terraform"
}

variable "deploy_branch" {
  type        = string
  description = "The branch of the repo to deploy."
  default     = "main"
}

variable "deploy_timeout" {
  type        = string
  description = "How long should the deploy wait before timing out."
  default     = "600s"
}
