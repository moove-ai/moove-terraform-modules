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
    function_service_account         = string
    function_service_account_project = string
  }))
}

variable "vaisala_api_key_secret_id" {
  type        = string
  description = "The secret ID for the Vaisala API key"
  default     = "vaisala_api_key"
}

variable "vaisala_api_key_secret_project" {
  type        = string
  description = "The secret ID project for the Vaisala API key"
  default     = "moove-secrets"
}
  