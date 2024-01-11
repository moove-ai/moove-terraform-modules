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

variable "pubsub_topic_name" {
  type        = string
  description = "The name of the pubsub topic to persist the contextualization data"
  default     = "contextualization-store"
}

variable "pubsub_subscription_name" {
  type        = string
  description = "The name of the pubsub subscription the application should listen on"
  default     = "contextualization-store-subscription"
}

variable "contextualization_service_account_name" {
  type        = string
  description = "The name of the contextualization service account"
  default     = "contextualization"
}

variable "contextualization_service_account_project" {
  type        = string
  description = "The name of the contextualization service account"
  default     = ""
}

variable "contextualization_store_bucket" {
  type        = string
  description = "The GCS bucket used to store the contextaulization data"
}

variable "contextualization_store_location" {
  type        = string
  description = "The location of the GCS bucket used to store the contextaulization data"
  default     = "us-central1"
}

variable "lifecycle_rules" {
  description = "The lifecycle rules to be applied to the input bucket. If this array is populated then each element in it will be applied as a lifecycle rule to this bucket. The structure of each element is described in detail here: https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule. See also: https://cloud.google.com/storage/docs/lifecycle#configuration."
  default     = []
}

variable "ack_deadline_seconds" {
  type        = number
  description = "The number of seconds the subscriber has to acknowledge each message pulled from the subscription"
  default     = 40
}
