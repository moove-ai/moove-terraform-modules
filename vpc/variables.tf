variable "project_id" {
  type        = string
  description = "The project to create the VPC on"
}

variable "network_name" {
  type        = string
  description = "The name of the VPC Network to create"
}

variable "environment" {
  type        = string
  description = "The environment this VPC is running in"
}

variable "shared_vpc_host" {
  description = "If true, this VPC will be able to share its network with other projects"
  type        = bool
  default     = true
}

variable "routing_mode" {
  type        = string
  description = "The routing mode for this VPC"
  default     = "GLOBAL"
}

variable "vpc_subnets" {
  type        = list(map(string))
  description = "A list of maps of subnets"
  default = [
    {
      subnet_name           = ""
      subnet_ip             = ""
      subnet_region         = ""
      subnet_private_access = ""
      description           = ""
    }
  ]
}

variable "secondary_ranges" {
  type        = map(list(object({ range_name = string, ip_cidr_range = string })))
  description = "Secondary ranges that will be used in some of the subnets"
  default     = {}
}

variable "routes" {
  type = list(map(string))
  default = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
  }]
}

variable "regions" {
  type        = list(string)
  description = "List of regions to create routers, nats, and VPC connectors"
}
