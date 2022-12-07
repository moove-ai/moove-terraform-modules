variable "network_name" {
  type        = string
  description = "The name of the network running in this environemt"
}

variable "network_project_id" {
  type        = string
  description = "The project the local network is being run in"
}

variable "remote_network_name" {
  type        = string
  description = "The name of the network to peer to"
}

variable "remote_network_project_id" {
  type        = string
  description = "The project the remote network is being run in"
}