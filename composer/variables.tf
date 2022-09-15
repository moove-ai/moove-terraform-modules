variable "project_id" {
  type        = string
  description = "The project to deploy this composer cluster on"
}

variable "region" {
  type        = string
  description = "The region to deploy the composer cluster on"
}

variable "" "composer_env_name" {
  type        = string
  description = "The name of the Composer cluster"
}

variable "" "network_project_id" {
  type        = string
  description = "The shared VPC host of the network"
}

variable "network" {
  type        = string
  description = "The name of the VPC network"
}

variable "subnetwork" {
  type        = string
  description = "The name of the subnetwork"
}

variable "master_ipv4_cidr" {
  type        = string
  description = "The IP CIDR for the main node"
}

variable "pod_ip_allocation_range_name" {
  type        = string
  description = "The name of the range for Pod IP allocation"
}

variable "service_ip_allocation_range_name" {
  type        = string
  description = "The name of the range for Service IP allocation"
}

variable "tags" {
  type        = set(string)
  description = "Set of tags to apply to this instance"
}

variable "private_endpoint" {
  type        = bool
  description = "Set to true to enable the private endpoing"
}

variable "use_private_environment" {
  type        = bool
  description = "Set to true to enforce the use of the private endpoint"
}

variable "" "environment_size" {
  type        = string
  description = "The environment size controls the performance parameters of the managed Cloud Composer infrastructure that includes the Airflow database. Values for environment size are: ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, and ENVIRONMENT_SIZE_LARGE."
}

variable "cloud_composer_network_ipv4_cidr_block" {
  type        = string
  description = "The CIDR block from which IP range in tenant project will be reserved."
}

variable "composer_service_account" {
  type        = string
  description = "The email of the composer service account"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the cluster"
}

variable "worker_resources" {
  type = object({
    cpu        = string
    memory_gb  = number
    storage_gb = number
    min_count  = number
    max_count  = number
  })
  description = "Configuration for resources used by Airflow workers."
}
