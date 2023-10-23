variable "create_serviceaccount" {
  type    = bool
  default = false
}

variable "serviceaccount_display_name" {
  type    = string
  default = "My Service Account"
}

variable "serviceaccount_description" {
  type    = string
  default = "This is my service account"
}

variable "serviceaccount_id" {
  type    = string
  default = ""
}

