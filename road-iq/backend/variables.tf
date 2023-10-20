variable "project_id" {
  type        = string
  description = "The project ID road-iq is running in"
}

variable "region" {
  description = "The region this is running in"
}

variable "service_account_id" {
  type        = string
  default     = "road-iq"
  description = "The name of the service account to create"
}

variable "service_account_project_id" {
  type        = string
  description = "The project ID to create the service account in"
  default     = ""
}

variable "service_account_description" {
  type        = string
  description = "The description of the service account"
  default     = "Service account for road-iq"
}

variable "service_account_display_name" {
  type        = string
  description = "The display name of the service account"
  default     = "road-iq"
}

variable "environment" {
  type        = string
  description = "The name of the environment to deploy road-iq to"
}

variable "create_service_account" {
  type        = bool
  description = "value to determine if service account should be created"
  default     = true
}

variable "postgres_address" {
  type        = string
  description = "The address of the postgres instance"
}

variable "auth0_domain" {
  type        = string
  description = "The domain of the auth0 instance"
}

variable "auth0_audience" {
  type        = string
  description = "The audience of the auth0 instance"
}

variable "auth0_token_domain" {
  type        = string
  description = "the domain of the auth0 token instance"
}

variable "db_instance_name" {
  type        = string
  description = "The name of the database instance"
}

variable "db_instance_tier" {
  type        = string
  description = "The tier of the database instance"
  default     = "db-f1-micro"
}

variable "clickhouse_host" {
  type        = string
  description = "The IP Address of the Clickhouse host"
}

variable "scoring_api_config_secret_id" {
  type        = string
  description = "The secret ID of the scoring API config"
  default     = "scoring-api-config"
}

variable "k8s_cluster_project_id" {
  type        = string
  description = "The project ID of the k8s cluster"
  default     = ""
}

variable "k8s_service_account_name" {
  type        = string
  description = "The name of the k8s service account"
  default     = ""
}

variable "k8s_namespace" {
  type        = string
  description = "The namespace of the k8s cluster"
  default     = ""
}

variable "db_instance_project_id" {
  type        = string
  description = "Optional. The project the SQL instance is in"
  default     = ""
}

variable "weather_bucket" {
  type        = string
  description = "The name of the weather bucket"
  default     = "weather-image-cache-road-iq-stage"
}

variable "bigquery_read_projects" {
  type        = list(string)
  description = "List of projects to assign bigquery dataviewer roles to"
}