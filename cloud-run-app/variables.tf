variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "build_project" {
  description = "The project ID to build the container image"
  type        = string
  default     = "moove-build"
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
}

variable "service_account_id" {
  description = "The service account ID to create"
  type        = string
}

variable "service_account_display_name" {
  description = "The service account display name"
  type        = string
  default     = ""
}

variable "service_account_description" {
  description = "The service account description"
  type        = string
  default     = ""
}

variable "create_service_account" {
  description = "Whether to create the service account"
  type        = bool
  default     = true
}

variable "service_account_project_id" {
  description = "The project ID the service account is in"
  type        = string
  default     = ""
}

variable "network_project_id" {
  type        = string
  description = "The project ID the network is in"
}

variable "application_name" {
  type        = string
  description = "The name of the application"
}

variable "pubsub_topic_message_retention_duration" {
  type        = string
  description = "The message retention duration for the pubsub topic"
  default     = "86600s"
}

variable "pubsub_subscription_message_retention_duration" {
  type        = string
  description = "The message retention duration for the pubsub subscription"
  default     = "1200s"
}

variable "pubsub_retain_acked_messages" {
  type        = bool
  description = "Whether to retain a pubsub subscription messages"
  default     = true
}

variable "pubsub_enabled" {
  type        = bool
  description = "Whether to create a pubsub topic and subscription"
  default     = false
}

variable "pubsub_subscription_name" {
  type        = string
  description = "The name of the pubsub subscription"
  default     = ""
}

variable "pubsub_topic_name" {
  type        = string
  description = "The name of the pubsub topic"
  default     = ""
}

variable "pubsub_expiration_policy" {
  description = "Expiration policy configuration"
  type        = map(string)
  default = {
    ttl = "300000.5s"
  }
}

variable "pubsub_retry_policy" {
  description = "Retry policy configuration"
  type        = map(string)
  default = {
    minimum_backoff = "10s"
  }
}

variable "pubsub_enable_message_ordering" {
  type        = bool
  description = "enable pubsub message ordering"
  default     = false
}

variable "pubsub_ack_deadline_seconds" {
  type        = number
  description = "The ack deadline seconds for the pubsub subscription"
  default     = 20
}
