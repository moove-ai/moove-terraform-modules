variable "create_serviceaccount" {
  type    = bool
  default = false
}

variable "serviceaccount_display_name" {
  type    = string
  default = ""
}

variable "serviceaccount_description" {
  type    = string
  default = ""
}

variable "serviceaccount_id" {
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

variable "gke_serviceaccount_name" {
  type        = string
  description = "The name of the GKE service account"
}
