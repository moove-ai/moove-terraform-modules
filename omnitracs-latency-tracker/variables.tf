variable "project_id" {
  type        = string
  description = "The project ID to create resources on"
  default     = "moove-systems"
}

variable "k8s_sa" {
  type        = string
  description = "The k8s service account running this application"
  default     = "omnitracs-latency-tracker"
}

variable "namespace" {
  type        = string
  description = "The k8s namespace the app is running in"
  default     = "monitoring"
}

variable "bucket" {
  type        = string
  default     = "moove-data-import-5nsnl6-us"
  description = "description"
}

variable "service_account" {
  type        = string
  default     = "k8s-omnitracs-latency-tracker"
  description = "The service account running this application"
}

variable "monitoring_project" {
  type        = string
  default     = "moove-systems"
  description = "The project BQ queries are executed in"
}
