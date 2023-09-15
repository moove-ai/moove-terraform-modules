variable "environment" {
  type        = string
  description = "The environment the function will be deployed to"

}

variable "project_id" {
  type        = string
  description = "The project ID the function will be deployed to"
}


variable "create_service_account" {
  type        = bool
  description = "value to determine if a service account should be created"
}

variable "service_account_project_id" {
  type        = string
  description = "The project the service account is located in"
  default     = ""
}

variable "service_account_id" {
  type        = string
  description = "The project the service account is located in"
  default     = ""
}

variable "service_account_display_name" {
  type        = string
  description = "The project the service account is located in"
  default     = ""
}

variable "service_account_description" {
  type        = string
  description = "The project the service account is located in"
  default     = ""
}

variable "buckets" {
  type        = list(string)
  description = "The name of the bucket to be created"
  default     = ["moove-aws-import"]
}
  