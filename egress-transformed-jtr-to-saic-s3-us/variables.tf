variable labels {
  type        = map(string)
  default = {
    function = "data-pipelines"
    pipeline = "join-to-roads"
    component = "egress"
    client = "saic"
  }
  description = "description"
}

variable "project_id" {
  type        = string
  description = "The project to deploy secrets to"
}

variable "namespace" {
  type        = string
  description = "The namespace to install secrets onto"
}
