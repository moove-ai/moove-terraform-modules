variable "project_id" {
  type        = string
  description = "The project ID to deploy the cloud build trigger on."
}

variable "function_name" {
  type        = string
  description = "The name of the cloud function"
}

variable "function_service_account" {
  type        = string
  description = "The service account running the cloud function"
}

variable "summary" {
  type        = string
  description = "Summary of the CF to be appended to the description."
}

variable "service_account" {
  type        = string
  description = "The name of the service account being used in the deploy"
}

variable "extra_tags" {
  type        = list(string)
  description = "List of tags to append to the cloud build trigger"
}

variable "build_branch" {
  type        = string
  description = "The branch being used to build the cloud function"
}

variable "environment" {
  type        = string
  description = "The environment the cloud function is running in"
}

variable "function_memory" {
  type        = string
  description = "How much memory to add to the function. valid values are: 256MB, 512MB, 1024MB, 2048MB"
}

variable "function_region" {
  type        = string
  description = "The region the function will run in"
}

variable "function_project_id" {
  type        = string
  description = "The project the function will run in"
}

variable "function_vpc_connector" {
  type        = string
  description = "The self link of the VPC connector to use. Only neeed for metrics"
}

variable "function_runtime" {
  type        = string
  default     = "python39"
  description = "The runtime of the cloudfunction. ex: python39, python38"
}

variable "function_log_level" {
  type        = string
  description = "The log level of the function"
}

variable "function_timeout" {
  type        = string
  description = "The timeout in seconds. Max is 540s"
  default     = "60s"
}


variable "build_trigger_files" {
  type        = list(string)
  description = "List of and patterns to trigger the deploy."
}

variable "build_ignore_files" {
  type        = list(string)
  description = "List of files and patterns which will not trigger a build when changed"
  default     = []
}

variable "repo_name" {
  type        = string
  description = "The name of the Git repo"
}

variable "function_entrypoint" {
  type        = string
  description = "The entrypoint function for the cloud function"
}

variable "function_label" {
  type        = string
  description = "The primary label to apply to the cloudfunction. Scoring, data-pipelines, geocoding, etc"
}

variable "function_trigger_topic" {
  type        = string
  description = "The pubsub to trigger the CF from"
  default     = ""
}

variable "pushgateway_port" {
  type        = string
  description = "The port to use with pushgateway"
  default     = "9091"
}

variable "pushgateway_url" {
  type        = string
  description = "The pushgateway URL for metrics"
}

variable "function_source" {
  type        = string
  description = "The path to the files which deploy the cloudfunction"
  default     = "."
}

variable "ci_cd_branch" {
  type        = string
  description = "The CI/CD branch to use"
}