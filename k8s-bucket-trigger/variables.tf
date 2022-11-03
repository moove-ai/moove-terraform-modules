# Common Variables
variable "project_id" {
  type        = string
  description = "The project ID to create these resources on"
}

variable "environment" {
  type        = string
  description = "The environment this module is running in"
}

variable "app_name" {
  type        = string
  description = "The name of the k8s app. Must match the name in the k8s-deployments repo"
}

variable "input_bucket" {
  type        = string
  description = "Objects created in this bucket will trigger a pub/sub notification to the configured topic"
}

variable "output_bucket" {
  type        = string
  description = "Bucket to hold the output of this app. Required if 'enable_output' is true"
  default     = ""
}

variable "enable_output" {
  type        = bool
  description = "Creates output resources"
  default     = true
}

variable "create_input_bucket" {
  type        = bool
  description = "Creates the input bucket if true"
  default     = true
}

variable "create_output_bucket" {
  type        = bool
  description = "Creates the output bucket if true"
  default     = true
}

variable "input_bucket_location" {
  type        = string
  description = "The region the input_bucket is located in"
  default     = "US"
}

variable "output_bucket_location" {
  type        = string
  description = "The region the input_bucket is located in"
  default     = "US"
}

variable "input_bucket_project" {
  type        = string
  description = "Optional. If the bucket is located in a different project, set this value. If create_input_bucket is set, the bucket will be created in this project."
  default     = ""
}

variable "output_bucket_project" {
  type        = string
  description = "Optional. If the bucket is located in a different project, set this value. If create_input_bucket is set, the bucket will be created in this project."
  default     = ""
}

variable "labels" {
  type        = map(string)
  description = "Map of additional labels to apply"
  default     = {}
}

variable "notification_enabled" {
  type        = bool
  description = "Set to false to disable the bucket notification. Useful for testing."
  default     = true
}

variable "ack_deadline_seconds" {
  type        = string
  description = "The ack deadline in seconds for the subscription."
  default     = "120"
}

variable "topic_name" {
  type        = string
  description = "Optional. Sets the topic name if set. If unset, the topic name defaults to the value of input_bucket"
  default     = ""
}

variable "subscription_name" {
  type        = string
  description = "Optional. Sets the subscription name if set. If unset, the topic name defaults to the value of input_bucket"
  default     = ""
}

variable "service_account_id" {}
variable "namespace" {}

variable "k8s_sa" {
  type = string
  description = "The name of the kubernetes service account."
  default = ""
}
