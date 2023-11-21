variable "project_id" {
  type = string
}

variable "create_service_account" {
  type    = bool
  default = false
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
  type = string
}

variable "environment" {
  type = string
}

variable "gke_service_account_name" {
  type = string
}
