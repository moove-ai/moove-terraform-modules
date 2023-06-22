variable "bucket_names" {
  type        = list(string)
  description = "List of existing buckets to monitor"
}
variable "topic_name" {}
variable "project_id" {}
variable "bucket_project" {}
