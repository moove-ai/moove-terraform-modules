variable "secret_project_id" {
    type = string
    description = "The project id where the secrets are stored"
    default = "moove-secrets"
}

variable "environment" {
    type = string
    description = "value of the environment variable"
    default = "production"
}
