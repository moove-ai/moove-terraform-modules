variable "environments" {
  type = map(object({
    project_id              = string
    region                  = string
    build_branch_pattern    = string
    cloud_function_function = string
  }))
}

variable "function_additional_roles" {
  type        = list(string)
  description = "List of additional roles to grant to the function service account at the project level"
  default     = []
}

variable "build_additional_substitutions" {
  type        = map(string)
  description = "Map of additional substitutions to pass to the build trigger"
  default     = {}
}

variable "function_name" {
  type        = string
  description = "The name of the cloud function"
}

variable "service_account_id" {
  type        = string
  description = "The service account ID that will be running the function"
}

### Build Varialbes ###
variable "build_ignored_files" {
  type        = list(string)
  description = "List of files to ignore when building the function"
  default     = []
}

variable "build_included_files" {
  type        = list(string)
  description = "List of files which when changed will trigger a build"
  default     = []
}

variable "build_project_id" {
  type        = string
  description = "The name of the project builds are running on"
  default     = "moove-build"
}

variable "build_service_account_id" {
  type        = string
  description = "The service account ID that will be running the builds"
  default     = "deployer"
}

variable "build_tags" {
  type        = list(string)
  description = "List of tags to apply to the build"
  default     = []
}

variable "github_repo" {
  type        = string
  description = "The github repo containing the function code"
}

variable "build_location" {
  type        = string
  description = "The location of the Cloud Build trigger"
  default     = "global"
}

variable "build_file" {
  type        = string
  description = "The name of the cloudbuild file to use"
  default     = ""
}

variable "function_labels" {
  type        = string
  description = "value of the labels to be applied to the function"
  default     = "null"
}

variable "example" {
  type        = map(string)
  description = "value of the labels to be applied to the function"
  default     = {}
}
