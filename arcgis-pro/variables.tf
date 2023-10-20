variable "project_id" {
  type        = string
  description = "The project ID"
  default     = "moove-road-iq-production"
}

variable "network_project_id" {
  type        = string
  description = "The network project ID"
  default     = "moove-network-production"
}

variable "zone" {
  type        = string
  description = "The zone"
  default     = "us-central1-a"
}

variable "name" {
  type        = string
  description = "The name"
  default     = "arcgis-pro-0"
}

variable "machine_type" {
  type        = string
  description = "The machine type"
  default     = "n1-standard-4"
}

variable "environment" {
  type        = string
  description = "The environment"
  default     = "production"
}

variable "region" {
  type        = string
  description = "The region"
  default     = "us-central1"
}

variable "image_family" {
  type        = string
  description = "The image family"
  default     = "windows-cloud"
}

variable "image_name" {
  type        = string
  description = "The image name"
  default     = "windows-2022"
}

variable "disk_size" {
  type        = number
  description = "The disk size"
  default     = 200
}

variable "user_list" {
  type        = list(string)
  description = "The user list"
  default     = ["alexm", "eyal", "justin"]
}

variable "bq_projects" {
  type        = list(string)
  description = "The BigQuery projects"
  default     = ["moove-road-iq-production", "moove-road-iq-staging"]
}

