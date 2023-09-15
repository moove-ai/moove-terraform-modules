variable "build_project" {
  description = "The project ID to build the container image"
  type        = string
  default     = "moove-build"
}

variable "environments" {
  type = map(object({
    project_id         = string
    network_project_id = string
  }))
}

variable "service_account_id" {
  description = "Optional. The service account ID"
  type        = string
  default     = ""
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

variable "regions" {
  type        = list(string)
  description = "The list of regions the cloud run service is deplpoyed tthe cloud run service is deplpoyed to"
  default     = []
}

variable "dns_project" {
  type        = string
  description = "Optional. The project holding the DNS Managed Zone"
  default     = "moove-systems"
}

variable "dns_zone" {
  type        = string
  description = "Optional. The DNS Managed Zone"
  default     = "moove-ai"
}

variable "cloud_run_project" {
  type        = string
  description = "The project ID where the cloud run service is deployed"
  default     = ""
}

variable "cloud_run_service_name" {
  type        = string
  description = "Optional. The name of the cloud run service"
  default     = ""
}

variable "dns_name" {
  type        = string
  description = "Optional if createing external load balancer resources. The FQDN of the cloud run service"
  default     = ""
}

variable "create_external_load_balancer" {
  type        = bool
  description = "Set to true to create external load balancer resources"
  default     = false
}
