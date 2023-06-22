variable "project_id" {
  type        = string
  description = "The project ID road-iq is running in"
}

variable "region" {
  description = "The region this is running in"
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

variable "network_project_id" {
  type        = string
  default     = ""
  description = "The name of the project the k8s network is in"
}

variable "vpc_network" {
  description = "The name of the VPC network"
}

variable "db_instance_name" {
  description = "The name of the PSQL database"
}

variable "db_instance_tier" {
  description = "The tier of the PSQL database"
  default = "db-f0-micro"
}
