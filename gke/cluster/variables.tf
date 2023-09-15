variable "environment" {
  type        = string
  description = "The environment to deploy these resources to"
}

variable "project_id" {
  type        = string
  description = "The project ID the cluster will be deployed in"
}

variable "cluster_name" {
  type        = string
  description = "The name of the GKE cluster to be created"
}

variable "region" {
  type        = string
  description = "The GCP Region to deploy this module into"
}

variable "create_resource_monitor" {
  type        = bool
  description = "Set to true to create a BQ database to monitor GKE spend"
  default     = false
}
