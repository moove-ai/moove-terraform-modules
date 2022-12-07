variable "environment" {
  type        = string
  description = "The environment Jupyter is running in"
}

variable "project_id" {
  type        = string
  description = "The project to deploy this modules resources onto"
}

variable "folder_id" {
  type        = string
  description = "The folder the environment is running in"
}

variable "service_account_id" {
  type        = string
  default     = "k8s-jupyter"
  description = "The name of the service account running jupyter"
}

variable "service_account_name" {
  type        = string
  default     = "Jupyter Notebooks (k8s)"
  description = "The pretty name of the service account running jupyter"
}

variable "namespace" {
  type        = string
  description = "The namespace running jupyter"
}

variable "k8s_sa_name" {
  type        = string
  default     = "jupyter"
  description = "The name of the k8s service account running jupyter"
}

variable "jupyter_domain" {
  type        = string
  description = "The domain Jupyter is running in. moove.co.in"
}

variable "jupyter_url" {
  type        = string
  description = "The complete URL for jupyter. dev.jupyter.moove.co.in"
}

variable "billing_account" {
  type        = string
  default     = "01C68D-9DA6E5-136FB8"
  description = "The billing account used for this service"
}

variable "support_email" {
  type        = string
  description = "(Required) Support email displayed on the OAuth consent screen. Can be either a user or group email. When a user email is specified, the caller must be the user with the associated email address. When a group email is specified, the caller can be either a user or a service account which is an owner of the specified group in Cloud Identity."
  default     = ""
}
