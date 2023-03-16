variable "labels" {
  type = map(string)
  default = {
    function        = "data-pipelines"
    pipeline        = "omnitracs"
    component       = "egress"
    outgoing_client = "wejo"
    incoming_client = "omnitracs"
    terraformed     = "true"
    source          = "manual-input"
  }
  description = "description"
}

variable "project_id" {
  type        = string
  description = "The project to deploy secrets to"
}

variable "k8s_secrets_email" {
  type        = string
  description = "The email of the k8s secrets service account"
}

variable "k8s_namespace" {
  type        = string
  description = "The namespace in kubernetes this app is deployed to"
}

variable "k8s_cluster_project" {
  type        = string
  description = "The project the k8s (GKE) cluster is running in"
}

variable "regions" {
  type        = list(string)
  default     = []
  description = "List of regions the app is deployed in"
}
