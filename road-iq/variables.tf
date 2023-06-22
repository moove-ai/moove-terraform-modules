variable "project_id" {
  type        = string
  description = "The project ID road-iq is running in"
}

variable "service_account_id" {
  type        = string
  default     = "k8s-road-iq"
  description = "The project ID road-iq is running in"
}

variable "namespace" {
  type        = string
  default     = ""
  description = "The name of the namespace to deploy road-iq to"
}

variable "environment" {
  type        = string
  description = "The name of the environment to deploy road-iq to"
}

variable "cluster_project_id" {
  type        = string
  default     = ""
  description = "The name of the project the k8s cluster is in"
}

variable "network_project_id" {
  type        = string
  default     = ""
  description = "The name of the project the k8s network is in"
}

variable "regions" {
  type        = list(string)
  description = "List of regions road-iq is running in"
}
