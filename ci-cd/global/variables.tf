variable "org_id" {
  type        = string
  description = "The organization Id"
}

variable "billing_account" {
  type        = string
  description = "The billing account used for this project"
}

variable "folder_id" {
  type        = string
  description = "The folder ID the build project should be assigned to"
}

variable "apis" {
  type        = list(string)
  description = "List of APIs to enable on the build project"
}

variable "k8s_projects" {
  type        = list(string)
  description = "List of projects where k8s clusters are located"
}

variable "run_projects" {
  type        = list(string)
  description = "List of projects where k8s clusters are located"
}

variable "regions" {
  type        = list(string)
  description = "List of regions to deploy the artificate registry repositories"
  default = [
    "us-central1",
    "us-west1",
  ]
}

variable "deploy_region" {
  type        = string
  description = "The region the cloud deploy pipelines will be created in"
  default     = "us-central1"
}

variable "pipeline_targets" {
  type = map(list(object({
    name            = string
    project_id      = string
    description     = string
    service_account = string
    deploy_project  = string
    deploy_region   = string
  })))
  default = {}
}

variable "secret_project_id" {
  type        = string
  default     = "moove-secrets"
  description = "The project holding cicd secrets"
}

variable "environment" {
  type        = string
  description = "The environment ci/cd pipelines are running in"
  default     = "mgmt"
}
