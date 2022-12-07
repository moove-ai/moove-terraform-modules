variable "project_id" {
  type        = string
  description = "The project to deploy this to"
}

variable "environment" {
  type        = string
  description = "The environment this automation is running in"
}


variable "build_files" {
  type        = list(string)
  default     = ["*.tf", "*/**.tf", "**/**.tf", "**.tf"]
  description = "List of files that will trigger this automation. DO NOT REMOVE."
}

variable "build_ignored_files" {
  type        = list(string)
  default     = ["README.md", "*/**.md"]
  description = "List of files that will NOT trigger this automation. DO NOT REMOVE."
}

variable "build_repo" {
  type        = string
  default     = "moove-terraform-modules"
  description = "The git repo holding terraform modules"
}

variable "build_branch" {
  type        = string
  default     = "main"
  description = "The branch which will trigger the generation of documentation when merged to"
}

variable "build_timeout" {
  type        = string
  default     = "300s"
  description = "description"
}

variable "build_tags" {
  type        = list(string)
  default     = []
  description = "description"
}
