variable labels {
  type        = map(string)
  default = {
    function = "data-pipelines"
    pipeline = "join-to-roads"
    component = "egress"
    client = "saic"
    terraformed = "true"
  }
  description = "description"
}

variable "project_id" {
  type        = string
  description = "The project to deploy secrets to"
}

variable "namespace" {
  type        = string
  description = "The namespace to install secrets onto"
}

variable "k8s_secrets_email" {
  type        = string
  description = "The email of the k8s secrets service account"
}

variable "gcp_service_account" {
  type = string
  description = "The service account being used to copy GCP data"
}