# Common Variables
variable "github_repo" {
  description = "The name of the GitHub repository to trigger the Cloud Build job"
  type        = string
}

variable "github_owner" {
  description = "The name of the GitHub owner to trigger the Cloud Build job"
  type        = string
  default = "moove-ai"
}

variable "build_project_id" {
  description = "The project ID where the Cloud Build job will be triggered"
  type        = string
  default = "moove-build"
}

# Test Trigger Variables
variable "test_build_name" {
  description = "The name of the Cloud Build trigger for the test step"
  type        = string
}

variable "test_build_branch_pattern" {
  description = "The branch pattern to trigger the Cloud Build job test step"
  type        = string
  default = ".*"
}

# Stage Trigger Variables
variable "stage_build_branch_pattern" {
  description = "The branch pattern to trigger the Cloud Build job for the stage step"
  type        = string
  default = ".*"
}

# Deploy Trigger Variables
variable "deploy_build_branch_pattern" {
  description = "The branch pattern to trigger the Cloud Build job for the deploy step"
  type        = string
  default = "main"
}

# Composer variables
variable "staging_clusters" {
  type = list(object({
    cluster_name   = string
    cluster_region = string
    project_id = string
  }))
  description = "List of staging clusters with their names and regions."
}

variable "production_clusters" {
  type = list(object({
    cluster_name   = string
    cluster_region = string
    project_id = string
  }))
  description = "List of staging clusters with their names, projects and regions."
}

# Deploy variables
variable "deployer_account_id" {
  type = string
  description = "The account ID of the service account used to deploy the dags"
  default = "deployer"
}

variable "deployer_project_id" {
  type = string
  description = "The project id of the service account used to deploy the dags"
  default = "moove-build"
}