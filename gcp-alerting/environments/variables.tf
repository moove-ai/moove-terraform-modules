variable "environment" {
    type = string
    description = "The environment this module is being deployed to"
}

variable "secret_project_id" {
    type = string
    description = "The project id where the secrets are stored"
    default = "moove-secrets"
}
  