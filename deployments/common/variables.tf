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

variable regions {
  type        = list(string)
  default     = ["us-central1"]
  description = "A list of regions to deploy the worker pools to"
}

variable machine_type {
  type        = string
  default     = "e2-standard-2"
  description = "The machine type used by this pool"
}
