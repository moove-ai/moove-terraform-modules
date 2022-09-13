variable "project_id" {
    type = string
    description = "The project ID to deploy cloud build automation to"
}

variable "secret_project_id" {
    type = string
    description = "The project holding common cloudbuild secrets"
    default = "moove-secrets"
}