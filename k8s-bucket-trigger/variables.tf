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
  type        = string
  description = "The name of the kubernetes service account."
  default     = ""
}

variable "input_bucket_retention_age" {
  type        = string
  description = "If set files will be deleted after n days from the input bucket."
  default     = ""
}

variable "output_bucket_retention_age" {
  type        = string
  description = "If set files will be deleted after n days from the input bucket."
  default     = ""
}

variable "input_bucket_client" {
  type        = string
  description = "The client with t"
}

variable "output_bucket_client" {
  type        = string
  description = "The client with t"
  default     = "moove"
}

variable "input_bucket_lifecycle_rules" {
  description = "The lifecycle rules to be applied to the input bucket. If this array is populated then each element in it will be applied as a lifecycle rule to this bucket. The structure of each element is described in detail here: https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule. See also: https://cloud.google.com/storage/docs/lifecycle#configuration."
  default     = []
}

variable "output_bucket_lifecycle_rules" {
  description = "The lifecycle rules to be applied to the output bucket. If this array is populated then each element in it will be applied as a lifecycle rule to this bucket. The structure of each element is described in detail here: https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule. See also: https://cloud.google.com/storage/docs/lifecycle#configuration."
  default     = []
}