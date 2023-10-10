variable "metrics_scope" {
  type        = string
  description = "The project that holds the metrics scopes"
}

variable "environment" {
  type        = string
  description = "The environment being monitored"
}

variable "secret_project_id" {
  type        = string
  description = "The project holding GCP secrets"
  default     = "moove-secrets"
}

variable "folder_id" {
  type        = string
  description = "The folder ID to monitor. Will get all projets in this folder. This module will need to be run again when a new project is added"
}

variable "ignored_projects" {
  type        = list(string)
  description = "List of projects to ignore when attaching monitoring scopes"
  default     = []
}
