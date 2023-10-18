variable "project_id" {
  description = "The ID of the project in which the resources will be managed."
  default     = "moove-data-pipelines-staging"
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket."
  default     = "moove-gcs-proxy-staging"
  type        = string
}

variable "create_bucket" {
  description = "Determines whether to create a GCS bucket."
  default     = true
  type        = bool
}

variable "bucket_location" {
  description = "The location where the GCS bucket will be created."
  default     = "US"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account."
  type        = string
}

variable "create_service_account" {
  description = "Determines whether to create a service account."
  default     = true
  type        = bool
}

variable "auth_secret_id" {
  type        = string
  description = "Secret ID for GCS Proxy auth token"
}

variable "bucket_force_destroy" {
  description = "Destroys bucket data if changes are made to the bucket."
  default     = false
  type        = bool
}
