variable "project_id" {
  type        = string
  description = "The project ID the SA/GKE cluster is in"
}

variable "service_account_id" {
  type        = string
  description = "The Account ID of the SA to create"
  default     = "k8s-bigquery-watcher"
}

variable "service_account_description" {
  type        = string
  description = "What is this SA About?"
  default     = "Runs the Bigquery Watcher kubernetes job. Records the sizes of all BQ datasets and saves the historical data."
}

variable "service_account_name" {
  type        = string
  description = "The SA Display Name"
  default     = "BigQuery Watcher"
}

variable "namespace" {
  type        = string
  description = "The k8s namespace the bigquery watcher app is running in"
  default     = "monitoring"
}

variable "k8s_sa_name" {
  type        = string
  description = "The k8s sa the bigquery watcher app is running as"
  default     = "bigquery-watcher"
}

variable "org_id" {
  type        = string
  description = "The org ID to monitor"
}