variable "wejo-import-bucket-us" {
  type        = string
  default     = "moove-data-import-ax4j9z-us"
  description = "The bucket incoming Wejo data is sent to"
}

variable "wejo-jtr-output-bucket-us" {
  type        = string
  default     = "moove-wejo-jtr-output-us"
  description = "The bucket incoming Wejo data is sent to"
}

variable "wejo-jtr-output-bucket-project-us" {
  type        = string
  default     = "moove-platform-production-data"
  description = "The bucket JTR wejo data is written to"
}

variable "wejo-jtr-export-bucket-us" {
  type        = string
  default     = "moove-wejo-jtr-syndication"
  description = "The bucket incoming Wejo data is sent to"
}

variable "wejo-import-bucket-us-project" {
  type        = string
  default     = "moove-platform-production-data"
  description = "The project the incoming Wejo bucket is in"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Map of labels to append"
}

variable "project_id" {
  type        = string
  description = "The project ID to deploy the join to roads resources to"
}

variable "join-to-roads-service-account" {
  type        = string
  default     = "k8s-join-to-roads"
  description = "The service account used to run the Join to Roads app"
}

variable "join-to-roads-k8s-service-account" {
  type        = string
  default     = "wejo-join-to-roads"
  description = "The service account used by k8s to run the Join to Roads app"
}

variable namespace {
  type        = string
  default     = "join-to-roads"
  description = "The k8s namespace to deploy to."
}

variable gke_cluster_project_id {
  type        = string
  description = "The project ID the GKE cluster is running on"
}

variable enable_notifications {
  type        = bool
  default     = true
  description = "Set to false to disable notifications. Useful for debugging and to avoid accidentally sending traffic live."
}

variable data-pipelines_project_id {
  type        = string
  description = "The project the data-pipelines resources are running in"
}
