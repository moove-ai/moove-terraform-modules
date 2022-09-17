variable "project_id" {}

variable "service_name" {
  type        = string
  description = "The name of the Cloud Run service"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy this Cloud Run service to."
}

variable "environment" {
  type        = string
  description = "The environment this service is running in"
}

variable "image_name" {
  type        = string
  description = "The name of the image"
  default     = "join-to-roads"
}

variable "build_project_id" {
  type        = string
  description = "The project ID that builds the container image"
}

variable "service_account_id" {
  type        = string
  description = "The name of the service account running join-to-roads"
}

variable "output_bucket" {
  type        = string
  description = "The name of the output bucket. Either the existing bucket, or a name of a bucket to be created."
}

variable "input_bucket" {
  type        = string
  description = "The name of the input bucket. Either the existing bucket, or a name of a bucket to be created."
  default     = "moove-data-import-ax4j9z-us"
}

variable "input_bucket_project" {
  type        = string
  description = "The name of the project hosting the input bucket"
  default     = "moove-data-import-pipelines"
}

variable "create_input_bucket" {
  type        = bool
  description = "Set to true to create the input bucket."
  default     = false
}

variable "create_output_bucket" {
  type        = bool
  description = "Set to true to create the output bucket."
  default     = true
}
