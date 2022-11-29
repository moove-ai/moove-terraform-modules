variable project_id {
  type        = string
  description = "The project to deploy this modules resources onto"
}

variable service_account_id {
  type        = string
  default     = "k8s-jupyter"
  description = "The name of the service account running jupyter"
}

variable service_account_name {
  type        = string
  default     = "Jupyter Notebooks (k8s)"
  description = "The pretty name of the service account running jupyter"
}

variable namespace {
  type        = string
  description = "The namespace running jupyter"
}

variable k8s_sa_name {
  type        = string
  default     = "jupyter"
  description = "The name of the k8s service account running jupyter"
}
