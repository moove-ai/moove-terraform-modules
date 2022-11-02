variable "project_id" {
  type        = string
  description = "The project the atlantis will be deployed to"
}

variable "environment" {
  type        = string
  description = "The project the atlantis will be deployed to"
}

variable "app_name" {
  type        = string
  description = "The name of the app"
  default     = "atlantis"
}

variable "build_service_account" {
  type        = string
  description = "The service account used for build automation"
}

variable "region" {
  type        = string
  description = "The region this app is running in"
}

variable "deployment_namespace" {
  type        = string
  description = "The namespace to deploy this app to"
  default     = "default"
}

variable "deployment_app_path" {
  type        = string
  description = "The path the build automation tracks changes for in the git_ops repo"
  default     = "atlantis"
}

variable "deployment_type" {
  type        = string
  description = "The type of deplpyment (apps or ops) this is"
  default     = "ops"
}

variable "secret_project_id" {
  type        = string
  description = "The project hosting the atlantis secret values"
  default     = "moove-secrets"
}
