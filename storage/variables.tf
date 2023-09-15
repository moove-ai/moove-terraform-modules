variable "name" {
  type        = string
  description = "The name of the bucket to create"
}

variable "project_id" {
  type        = string
  description = "The project this bucket is located in"
}

variable "location" {
  type        = string
  default     = "US"
  description = "What GCP location should this bucket be stored in"
}

variable "environment" {
  type        = string
  description = "The environment using this bucket"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Map of labels to apply to this bucket"
}

variable "lifecycle_rules" {
  description = "The lifecycle rules to be applied to the input bucket. If this array is populated then each element in it will be applied as a lifecycle rule to this bucket. The structure of each element is described in detail here: https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule. See also: https://cloud.google.com/storage/docs/lifecycle#configuration."
  default     = []
}

variable "admin_members" {
  type        = list(string)
  default     = []
  description = "List of members to give storage object admin access to. eg: user:jane@example.com"
}

variable "read_members" {
  type        = list(string)
  default     = []
  description = "List of members to give storage object read only access to. eg: user:jane@example.com"
}

variable "create_bucket" {
  type        = bool
  default     = true
  description = "Set to false to use an existing bucket"
}

variable "bucket_project" {
  type        = string
  default     = ""
  description = "Optional. Overrides the project to create or view the bucket in."
}


variable "create_service_account" {
  type        = bool
  default     = true
  description = "Set to false to use an existing service account"
}

variable "notification_enabled" {
  type        = bool
  description = "Set to false to disable the bucket notification. Useful for testing."
  default     = false
}

variable "service_account_project_id" {
  type        = string
  default     = ""
  description = "Optional. Sets the project for an existing service account"
}

variable "service_account_id" {
  type        = string
  description = "The name of the service account. Either uses an existing account or creates a new one."
}

variable "service_account_description" {
  type        = string
  default     = ""
  description = "The description for the service account if creating"
}

variable "service_account_name" {
  type        = string
  default     = "service account"
  description = "The description for the service account if creating"
}


variable "topic_name" {
  type        = string
  default     = ""
  description = "Optional. Sets the name of the GCS storage notification topic. Only used if notification_enabled is true"
}

variable "subscription_name" {
  type        = string
  default     = ""
  description = "Optional. Sets the name of the GCS storage notification subscription. Only used if notification_enabled is true"
}

variable "ack_deadline_seconds" {
  type        = string
  default     = "60"
  description = "Optional. Sets the ack deadline for this pub/sub subscription"
}

variable "subscription_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable a pub/sub subscription"
}

variable "admin_access" {
  type        = string
  default     = true
  description = "Optional. Gives the service account admin access to the bucket created/defined by this module."
}

variable "notification_prefix" {
  type        = string
  default     = ""
  description = "description"
}

# Client Variables
variable "client_bucket" {
  type        = bool
  default     = false
  description = "Optional. Set to true to create client bucket resources. Client Service Account, optional HMAC keys, and optional service account key"
}

variable "client_id" {
  type        = string
  default     = ""
  description = "Optional. Used for client buckets only. The 6 digit client ID string assigned to this client."
}

variable "client_name" {
  type        = string
  default     = ""
  description = "Optional. Used for client buckets only. Sets the name of the client"
}

variable "client_hmac_key" {
  type        = bool
  default     = false
  description = "Optional. Set to true to create an HMAC key for the client. Stored in a secret."
}

variable "client_sa_key" {
  type        = bool
  default     = false
  description = "Optional. Set to true to create a gcp service account key for the client. Stored in a secret."
}

variable "secret_project" {
  type        = string
  default     = "moove-secrets"
  description = "The project holding client secrets"
}

variable "cloud_function_enabled" {
  type        = bool
  description = "Set to true to create cloud function resources"
  default = false
}

variable "storage_transfer_enabled" {
  type        = bool
  description = "Set to true to create STS resources"
  default = false
}

variable "storage_transfer_project" {
  type        = string
  description = "The project the STS is running in"
  default = ""
}
