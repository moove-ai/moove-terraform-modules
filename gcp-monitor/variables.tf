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

variable "monitored_projects" {
  description = "List of project IDs to monitor"
  type        = list(string)
}
