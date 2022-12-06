variable "project_id" {
  type        = string
  description = "The project ID to deploy cloud build automation to"
}

variable "secret_project_id" {
  type        = string
  description = "The project holding common cloudbuild secrets"
  default     = "moove-secrets"
}

variable "environment" {
  type        = string
  description = "The environment for the build setup"
}

variable "build_cache_bucket_location" {
  type        = string
  description = "The location of the build cache bucket"
  default = "US"
}

variable "build_logs_bucket_location" {
  type        = string
  description = "The location of the build cache bucket"
  default = "US"
}
