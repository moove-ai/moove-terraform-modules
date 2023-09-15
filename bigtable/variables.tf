variable "instance_name" {
  type        = string
  description = "Name of the bigtable instance to create"
}

variable "project_id" {
  type        = string
  description = "The project this bucket is located in"
}

variable "cluster_id" {
  type        = string
  description = "Id of the bigtable cluster to create"
}

variable "clusters" {
  description = "Clusters to add to a Bigtable instance. Structure is described here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigtable_instance#nested_cluster"
  default     = []
}

variable "storage_type" {
  type        = string
  description = "Zone to create the bigtable cluster in"
  default     = "SDD"
}

variable "zone" {
  type        = string
  description = "Zone to create the bigtable cluster in"
  default     = "us-central1"
}

variable "min_nodes" {
  type        = string
  description = "Min nodes to allocate to a cluster"
  default     = 2
}

variable "max_nodes" {
  type        = string
  description = "Max nodes to allocate to a cluster"
  default     = 16
}

variable "cpu_target" {
  type        = string
  description = "Target CPU usage % for autoscaling"
  default     = 60
}

variable "storage_target" {
  type        = string
  description = "Target storage usage GB for autoscaling"
  default     = 2560
}

variable "deletion_protection" {
  type        = string
  description = "False if terraform should be allowed to destroy an instance"
  default     = true
}

variable "table_name" {
  type        = string
  description = "Name of a table in bigtable"
}

variable "column_family" {
  type        = string
  description = "Name of a column family"
}

variable "gc_rules" {
  type    = string
  default = <<EOF
  {
    "mode": "intersection",
    "rules": [
      {
        "max_age": "32d"
      },
      {
        "max_version": 1
      }
    ]
  }
  EOF
}

variable "app_profile_id" {
  type        = string
  description = "ID of and app profile"
}

variable "app_profile_description" {
  type        = string
  description = "Description of an app profile"
  default     = null
}

variable "multi_cluster_routing_use_any" {
  type        = string
  description = "Send requests to nearest cluster"
  default     = false
}

variable "allow_transactional_writes" {
  type        = string
  description = "Allow CheckAndMutateRow and ReadModifyWriteRow requests"
  default     = false
}

variable "app_profile_ignore_warnings" {
  type        = string
  description = "Ignore safetly checks when deleting/updating app profile"
  default     = false
}

