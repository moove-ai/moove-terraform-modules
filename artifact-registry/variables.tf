variable project_id {
  type        = string
  description = "The project ID this repo is running in"
}

variable environment {
  type        = string
  description = "The environment this artifact repo is running in"
}

variable region {
  type        = string
  description = "The region this repository is located in"
}

variable repository_id {
  type        = string
  description = "The ID of the repository"
}

variable repository_description {
  type        = string
  description = "The description of the repository"
}

variable format {
  type        = string
  description = "The format of the repository. Ex. DOCKER"
}
