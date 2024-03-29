variable "project_id" {
  type        = string
  description = "The name of the project to deploy the view to."
}

variable "shared_dataset" {
  type        = string
  description = "The name of the dataset (to be created) which will hold views of the source_project"
}

variable "shared_dataset_project" {
  type        = string
  description = "The project the dataset being shared is located in."
}

variable "source_dataset" {
  type        = string
  description = "The internal dataset being shared."
}

variable "views" {
  description = "A list of objects which include table_id, which is view id, and view query"
  default     = []
  type = list(object({
    view_id        = string,
    query          = string,
    use_legacy_sql = bool,
    labels         = map(string),
  }))
}

variable "email_list" {
  type        = list(string)
  description = "List of emails to share access with"
}
