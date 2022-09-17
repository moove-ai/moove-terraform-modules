variable "service_name" {
  type = string
  description = "The name of the Cloud Run service"
}

variable "region" {
  type = string
  description = "The GCP region to deploy this Cloud Run service to."
}

variable "image" {
  type = string
  description = "The Docker image this service uses"
}

variable "environment" {
  type = string
  description = "The environment this service is running in"
}

variable "image_name" {
  type = string
  description = "The name of the image"
  default = "join-to-roads"
}

variable "build_project_id" {
  type = string
  description = "The project ID that builds the container image"
}
