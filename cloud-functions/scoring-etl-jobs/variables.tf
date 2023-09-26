variable "build_service_account" {
  type        = string
  description = "The build service account ID"
  default     = "deployer"
}

variable "build_service_account_project" {
  description = "The build service account project"
  default     = "moove-build"
}

variable "environments" {
  type = map(object({
    function_project_id              = string
    function_service_account         = string
    function_service_account_project = string
  }))
}

variable "project_roles" {
  type        = list(string)
  description = "The roles to grant to the service account on the project"
  default     = []
}

variable "dataset_roles" {
  description = "Map of environments to projects, datasets, and roles"
  type        = map(any)
}
