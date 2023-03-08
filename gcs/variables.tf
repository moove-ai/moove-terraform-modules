variable "name" {
  type        = string
  description = "The name of the GCS bucket to create"
}

variable "project_id" {
  type        = string
  description = "The project the bucket is in"
}

variable "location" {
  type        = string
  description = "The Storage Location for the bucket us-central1, US, etc."
}

variable "client" {
  type        = string
  description = "The client this bucket is being used for"
}

variable "environment" {
  type        = string
  description = "The environment this bucket is running in"
}

variable "lifecycle_rules" {
  description = "The lifecycle rules to be applied to the bucket. If this array is populated then each element in it will be applied as a lifecycle rule to this bucket. The structure of each element is described in detail here: https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule. See also: https://cloud.google.com/storage/docs/lifecycle#configuration."
  default     = []
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "List of additonal labels to add"
}
