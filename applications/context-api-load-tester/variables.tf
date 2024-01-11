variable "project_id" {
  type        = string
  description = "The project id of the project where the service account will be created"
}

variable "secret_project_id" {
  type        = string
  description = "the project id of the project where the secret is stored"
  default     = "moove-secrets"
}

variable "service_account_id" {
  type        = string
  description = "value of the account_id variable"
  default     = "context-api-load-tester"
}

variable "service_account_display_name" {
  type        = string
  description = "value of the display_name variable"
  default     = "context-api-load-tester"
}

variable "service_account_description" {
  type        = string
  description = "value of the description variable"
  default     = "Used in the context-api-load-tester module"
}

variable "api_key_secret_id" {
  type        = string
  description = "The secret id of the api key"
}

variable "k8s_cluster_project_id" {
  type        = string
  description = "The project id of the project where the k8s cluster is running"
}

variable "k8s_namespace" {
  type        = string
  description = "The namespace where the k8s service account will be created"
}

variable "k8s_service_account_name" {
  type        = string
  description = "The name of the k8s service account"
}
