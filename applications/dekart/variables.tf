variable "project_id" {
  type        = string
  description = "The project ID the PSQL database is being created in"
}

variable "network_project_id" {
  type        = string
  description = "The project ID the PSQL database network is running on."
}

variable "environment" {
  type        = string
  description = "The environment dekart is running in"
}

variable "database_name" {
  type        = string
  description = "The name of the PSQL database"
  default     = "dekart"
}

variable "database_instance_name" {
  type        = string
  description = "The name of the PSQL database"
  default     = "dekart"
}

variable "region" {
  type        = string
  description = "The region the PSQL database is being created in"
  default     = "us-central1"
}

variable "database_version" {
  type        = string
  description = "The version the database is running. Must be a Postgres"
  default     = "POSTGRES_14"
}

variable "deletion_protection" {
  type        = string
  description = "Set to false to enable deletion of the database if data is present"
  default     = "true"
}

variable "database_tier" {
  type        = string
  description = "The instance running the PSQL database"
  default     = "db-f1-micro"
}

variable "dekart_serviceaccount" {
  type        = string
  description = "The service account running dekart"
  default     = "dekart"
}

variable "org_id" {
  type        = string
  description = "The organization ID to give dekart permissions to"
  default     = "294866853178"
}

variable "dekart_org_roles" {
  type        = list(string)
  description = "List of roles to assign the dekart service account. Applies to the entire org"
  default = [
    "roles/bigquery.dataViewer",
    "roles/bigquery.readSessionUser"
  ]
}

variable "dekart_project_roles" {
  type        = list(string)
  description = "List of roles to apply to the dekart project"
  default = [
    "roles/bigquery.jobUser"
  ]
}

variable "dekart_bq_project" {
  type        = string
  description = "The project Drkart runs bigquery queries in. Must match the environment variable defined in the dekart deployment (k8s-apps)"
}

variable "create_bucket" {
  type        = bool
  description = "value to determine if a bucket should be created for dekart"
  default     = true
}

variable "bucket_name" {
  type        = string
  description = "The name of the existing bucket to use for dekart"
  default     = ""
}

variable "bucket_location" {
  type        = string
  description = "The name of the existing bucket to use for dekart"
  default     = "US"
}

variable "create_database" {
  type        = bool
  description = "Determines if the psql database should be created"
  default     = true
}

variable "bucket_force_destroy" {
  type        = bool
  description = "The name of the existing bucket to use for dekart"
  default     = false
}