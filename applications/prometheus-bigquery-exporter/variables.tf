variable "project_id" {
  type        = string
  description = "The project ID the exporter will be deployed to"
}

variable "k8s_cluster_project" {
  type        = string
  description = "The project ID of the GKE cluster"
  default     = ""
}

variable "k8s_namespace" {
  type        = string
  description = "The namespace of the GKE cluster"
  default     = ""
}

variable "k8s_service_account_name" {
  type        = string
  description = "The name of the service account"
  default     = "prometheus-bigquery-exporter"
}

variable "environment" {
  type        = string
  description = "The environment the exporter will be deployed to"
}

variable "service_account_description" {
  type        = string
  description = "The description of the service account"
  default     = "Prometheus BigQuery Exporter"
}

variable "service_account_display_name" {
  type        = string
  description = "The display name of the service account"
  default     = "Prometheus Bigquery Exporter"
}

variable "service_account_id" {
  type        = string
  description = "The ID of the service account"
  default     = "prometheus-bigquery-exporter"
}

variable "bigquery_dataset_id" {
  type        = string
  description = "The ID of the BigQuery dataset"
  default     = "prometheus_bigquery_exporter"
}

variable "bigquery_dataset_friendly_name" {
  type        = string
  description = "The friendly name of the BigQuery dataset"
  default     = "Prometheus BigQuery Exporter"
}

variable "bigquery_dataset_description" {
  type        = string
  description = "The description of the big query dataset"
  default     = "Dataset holding exported Prometheus metrics"
}

variable "bigquery_dataset_location" {
  type        = string
  description = "The location of dataset"
  default     = "US"
}

variable "bigquery_project_id" {
  type        = string
  description = "The ID of the BigQuery project"
  default     = ""
}

variable "bigquery_table_id" {
  type        = string
  description = "The ID of the BigQuery table"
  default     = "contextualization_metrics"
}

variable "bigquery_table_partition_expiration_ms" {
  type        = number
  description = "The number of milliseconds for which to keep the storage for a partition"
  default     = 15552000000 # 180 days
}

variable "bigquery_table_schema" {
  type        = string
  description = "The schema of the BigQuery table"
  default     = <<EOF
[
    {
        "name": "timestamp",
        "type": "TIMESTAMP",
        "mode": "REQUIRED"
    },
    {
        "name": "timestamp_day",
        "type": "DATE",
        "mode": "REQUIRED"
    },
    {
        "name": "api_call_id",
        "type": "STRING"
    },
    {
        "name": "client_id",
        "type": "STRING",
        "mode": "REQUIRED"
    },
    {
        "name": "points_type",
        "type": "STRING"
    },
    {
        "name": "request_status",
        "type": "STRING"
    },
    {
        "name": "metric_name",
        "type": "string",
        "mode": "REQUIRED"
    },
    {
        "name": "metric_value",
        "type": "FLOAT"
    },
    {
        "name": "metric_delta",
        "type": "FLOAT"
    }
]
EOF
}

variable "deletion_protection" {
  type        = bool
  description = "Whether the table is protected against deletion"
  default     = false
}