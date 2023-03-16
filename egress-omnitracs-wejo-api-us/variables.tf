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
