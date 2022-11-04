variable "monitored_projects" {
  type        = list(string)
  description = "A list of projects to include in the monitoring scope"
}

variable "metrics_scope" {
  type        = string
  description = "The project that holds the metrics scopes"
}

variable "environment" {
  type        = string
  description = "The environment being monitored"
}
