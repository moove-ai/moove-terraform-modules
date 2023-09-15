variable "project_id" {
  type        = string
  default     = "moove-systems"
  description = "The project ID for this"
}

variable "cluster_project_id" {
  type        = string
  default     = "moove-systems"
  description = "The project ID for this"
}

variable "regions" {
  type        = list(string)
  description = "List of regions the monitoring application is being deployed to. Needed for GKE workload identity."
}

variable "secret_project_id" {
  type        = string
  description = "The project ID where secrets are stored"
  default     = "moove-secrets"
}

variable "environment" {
  type        = string
  description = "The environment the monitoring stack is running in"
  default     = "mgmt"
}
