variable "project_id" {
  type        = string
  description     = "The project the cloud run service is being deployed to"
}

variable "region" {
  type        = string
  description     = "The region the cloud run service is being deployed to"
}

variable "service_name" {
  type        = string
  description     = "The name of the cloud run service"
}

variable "service_description" {
  type        = string
  description     = "The name of the cloud run service"
}

variable "extra_tags" {
  type        = list(string)
  description     = "List of tags to apply to the CI/CD deployment"
  default = []
}

variable "repo_name" {
  type        = string
  description     = "The name of the repo holding the cloud run service"
}

variable "ci_cd_branch" {
  type        = string
  description     = "The branch to deploy off of"
  default     = "main"
}

variable "environment" {
  type        = string
  description     = "The environment this service is running in"
}

variable "cron_schedule" {
  type        = string
  description     = "Creates a cron service if present. Should be in cron tab format"
  default = ""
}

variable "service_account" {
  type        = string
  description     = "The service account used to run this service"
}

variable "cpu_throttling_flag" {
  type        = string
  description     = "CPU Throttling flag for the deployment. Options are: --cpu-throttling --no-cpu-throttling"
  default = "--cpu-throttling"
}

variable "build_service_account" {
  type        = string
  description     = "The service account used to run this service"
}

variable "build_trigger_files" {
  type        = list(string)
  description     = "List of files to trigger builds"
}

variable "build_ignore_files" {
  type        = list(string)
  description     = "List of files to ignore"
  default = []
}

variable "network_project" {
  type = string
  description = "the project the network is running on."
}