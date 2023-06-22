variable "client_name" {
  type        = string
  description = "The name of the client. This does not get added to any bucket or service account names for privacy reasons"
}

variable "location" {
  type        = string
  description = "The location this bucket is being stored in. US or EU"
}

variable "secret_project" {
  type        = string
  default     = "moove-secrets"
  description = "The project the client id secret is saved to"
}
