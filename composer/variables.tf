variable "project_id" {
  type        = string
  description = "The project to deploy this composer cluster on"
}

variable "environment" {
  type        = string
  description = "The environment this cluster is running in."
}

variable "composer_service_account" {
  type        = string
  description = "The email of the composer service account"
  default     = ""
}

variable "create_service_account" {
  type        = bool
  description = "If true, creates a service account for the cluster to use. Default service account is '$composer_env_name@$PROEJCT_ID'"
}

variable "service_account_name" {
  type    = string
  default = ""
}

variable "composer_alerts_secret_id" {
  type        = string
  description = "The secret id for the composer alerts secret"
  default     = "monitoring_pagerduty-airflow-alerts-key"
}

variable "secret_project_id" {
  type        = string
  description = "The project id where the secret is stored"
  default     = "moove-secrets"
}
