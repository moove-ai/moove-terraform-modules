variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "labels" {
  description = "Map of labels to merge onto this service"
  type        = map(string)
  default     = {}
}

variable "build_project" {
  description = "The project ID to build the container image"
  type        = string
  default     = "moove-build"
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "service_location" {
  description = "Location of the Cloud Run service"
  type        = string
}

variable "launch_stage" {
  description = "Launch stage of the Cloud Run service"
  type        = string
  default     = "BETA"
}

variable "ingress" {
  description = "Ingress of the Cloud Run service"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "containers" {
  description = "List of container configurations"
  type = list(object({
    name       = string
    image      = string
    port       = number
    depends_on = optional(list(string))
    volume_mounts = list(object({
      name       = string
      mount_path = string
    }))
    liveness_probe = optional(list(object({
      initial_delay_seconds = optional(number)
      timeout_seconds       = optional(number)
      period_seconds        = optional(number)
      failure_threshold     = optional(number)
      http_get = optional(list(object({
        path   = string
        port   = number
        host   = optional(string)
        scheme = optional(string)
        http_headers = optional(list(object({
          name  = string
          value = string
        })))
      })))
      grpc = optional(list(object({
        port = number
      })))
    })))
  }))
  default = []
}


variable "volumes" {
  description = "List of volume configurations"
  type = list(object({
    name       = string
    medium     = string
    size_limit = string
  }))
  default = []
}
