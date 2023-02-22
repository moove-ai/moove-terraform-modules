variable org_id {
  type        = string
  description = "The organization Id"
}

variable billing_account {
  type        = string
  description = "The billing account used for this project"
}

variable folder_id {
  type        = string
  description = "The folder ID the build project should be assigned to"
}

variable apis {
  type        = list(string)
  description = "List of APIs to enable on the build project"
}
