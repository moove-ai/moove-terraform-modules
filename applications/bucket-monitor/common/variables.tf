variable "regions" {
  type        = list(string)
  default     = ["us-west1", "us-central1"]
  description = "List of regions this app is deployed in"
}

variable "k8s_cluster_project" {
  type        = string
  default     = "moove-systems"
  description = "description"
}

variable "k8s_namespace" {
  type        = string
  default     = "monitoring"
  description = "description"
}
