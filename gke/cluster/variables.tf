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

variable proxy_zone {
  type        = string
  description = "The zone to create the GKE proxy in"
}

variable cluster_network_project_id {
  type        = string
  description = "The project the cluster network is located in"
}

variable cluster_network {
  type        = string
  description = "The name of the VPC network"
}

variable cluster_subnetwork {
  type        = string
  description = "The subnetwork the cluster is running on"
}

variable proxy_dns {
  type        = string
  description = "The DNS name for the proxy"
  default = ""
}

variable "create_resource_monitor" {
  type = bool
  description = "Set to true to create a BQ database to monitor GKE spend"
  default = false
}