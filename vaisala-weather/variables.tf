variable "project_list" {
  description = "List of projects"
  type        = list(string)
  default     = [] # Default to an empty list. You can provide values when calling this module or configuration.
}

variable "composer_serviceaccount" {
  type        = string
  description = "Service account used by the composer environment"
}

variable "function_serviceaccount" {
  type        = string
  description = "Service account used by the cloud function"
}

variable "region" {
  type        = string
  description = "the region the cloud functions are deployed to"
}