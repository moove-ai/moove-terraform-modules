variable "environments" {
  type = map(object({
    project_id           = string
    bucket_name          = string
    create_bucket        = bool
    bucket_location      = string
    service_account_name = string
  }))
}

variable "auth_secret_id" {
  type        = string
  description = "Secret ID for GCS Proxy auth token"
}
