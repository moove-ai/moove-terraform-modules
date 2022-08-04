variable "project_id" {
  type = string
  description = "The project the thanos object store is to be created on"
}

variable "cluster_name" {
  type = string
  description = "The name of the GKE cluster thanos is to be setup on"
}