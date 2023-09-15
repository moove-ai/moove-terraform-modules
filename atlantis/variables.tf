# Common
variable "project_id" {
  type        = string
  description = "The project the atlantis will be deployed to"
}

variable "environment" {
  type        = string
  description = "The project the atlantis will be deployed to"
}

variable "secret_project_id" {
  type        = string
  description = "The project hosting the atlantis secret values"
  default     = "moove-secrets"
}

# Deployment
variable "app_name" {
  type        = string
  description = "The name of the app"
  default     = "atlantis"
}

variable "service_account_name" {
  type        = string
  description = "The name of the app"
  default     = "atlantis"
}

variable "build_project_id" {
  type        = string
  description = "The project ID Builds are run on"
  default     = "moove-build"
}

variable "org_id" {
  type        = string
  description = "ORG ID that atlantis is running in"
  default     = "294866853178"
}
