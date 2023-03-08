variable "project_id" {
  type        = string
  description = "The project the worker pools will be deployed to"
}

variable "regions" {
  type        = list(string)
  default     = ["us-central1"]
  description = "A list of regions to deploy the worker pools to"
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "The machine type used by this pool"
}

variable "network_project" {
  type        = string
  description = "The project the Shared VPC is in"
}

variable "environment" {
  type        = string
  description = "The environment this is running in"
}
