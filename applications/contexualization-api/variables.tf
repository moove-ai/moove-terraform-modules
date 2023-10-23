variable "project_id" {
  type        = string
  description = "The project ID the app resources are in"
}

variable "create_service_account" {
  type    = bool
  default = true
}

variable "service_account_display_name" {
  type    = string
  default = ""
}

variable "service_account_description" {
  type    = string
  default = ""
}

variable "service_account_id" {
  type    = string
  default = ""
}

variable "gke_project_id" {
  type        = string
  description = "The project ID the GKE cluster is running in"
}

variable "environment" {
  type        = string
  description = "The environment the app is running in"
}

variable "gke_service_account_name" {
  type        = string
  description = "The name of the GKE service account"
}

variable "bigtable_instance_name" {
  type        = string
  description = "The name of the Bigtable instance"
  default     = "contextualization"
}

variable "client_list" {
  type = list(string)

}

variable "api_key_main_secret_name" {
  default = "contextualization-api-keys"
}
