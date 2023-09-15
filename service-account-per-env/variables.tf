variable "account_id" {
  type        = string
  description = "The ID of the service account"
}

variable "display_name" {
  type        = string
  description = "The display name of the service account"
}

variable "description" {
  type        = string
  description = "The description of the service account"
}

variable "environments" {
  type = map(object({
    project_id = string
  }))
}