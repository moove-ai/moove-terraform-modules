# 
variable "environment" { 
  type        = string
  description = "The environment to deploy these resources to"
}

#
variable "project_id" {
  type        = string
  description = "The project ID the cluster will be deployed in"
}

#
variable "cluster_name" {
  type        = string
  description = "The name of the GKE cluster to be created"
}

#
variable "region" {
  type        = string
  description = "The GCP Region to deploy this module into"
}

#
variable "cluster_network" {
  type        = string
  description = "The VPC network the cluster is going to run in"
}

#
variable "cluster_network_project_id" {
  type        = string
  description = "The name of the project the VPC resides in."
}

variable "proxy_dns_name" {
  type = string
  description = "The DNS Name of the GKE proxy"
}

variable "install_argocd" {
  type = bool
  description = "Installs helm chart."
  default = true
}

variable "install_common_resources" {
  type = bool
  description = "Installs helm chart."
  default = true
}

variable "install_cert_manager" {
  type = bool
  description = "Installs helm chart."
  default = true
}

variable "install_cert_manager_pilot" {
  type = bool
  description = "Installs helm chart."
  default = true
}

variable "install_external_dns" {
  type = bool
  description = "Installs helm chart."
  default = true
}

variable "install_external_secrets" {
  type = bool
  description = "Installs helm chart."
  default = true
}

variable "install_external_secrets_pilot" {
  type = bool
  description = "Installs helm chart."
  default = true
}

variable "install_keda" {
  type = bool
  description = "Set to true to install keda"
  default = true
}
