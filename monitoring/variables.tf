variable "project_id" {
  type        = string
  default     = "moove-systems"
  description = "The project ID for this"
}

variable "cluster_project_id" {
  type        = string
  default     = "moove-systems"
  description = "The project ID for this"
}

variable "regions" {
  type        = list(string)
  description = "List of regions the monitoring application is being deployed to. Needed for GKE workload identity."
}
