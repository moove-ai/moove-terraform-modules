variable "cloud_build_service_account" {
    type = string
    description = "Cloud Build Service Account"
    default = "builder"
}

variable "cloud_build_project_id" {
    type = string
    description = "Cloud Build Service Account"
    default = "moove-build"
}

variable "composer_projects" {
    type = list(string)
    description = "List of DAG projects"
}
