variable "project_id" {
  type        = string
  description = "The project ID the cluster will be deployed in"
}

variable cluster_network_project_id {
  type        = string
  description = "The project the cluster network is located in"
}

variable cluster_network {
  type        = string
  description = "The name of the VPC for this environment"
}
