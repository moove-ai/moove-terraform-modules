variable "project_id" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "environment" {
  type = string
}

variable "app_id" {
  type = string
}

variable "display_name" {
  type = string
}

variable "api_config_id" {
  type = string
}

variable "api_gateway_id" {
  type = string
}

variable "region" {
  type = string
}

variable "neg_name" {
  type        = string
  description = "The name of the NEG to create"
}

variable "neg_default_port" {
  type    = string
  default = "443"
}

variable "network_endpoint_type" {
  type    = string
  default = "INTERNET_FQDN_PORT"
}

variable "backend_service_name" {
  type = string
}

variable "backend_service_protocol" {
  type    = string
  default = "HTTP2"
}

variable "domain_name" {
  type        = string
  description = "The name of the HTTPS domain"
}

variable "dns_zone" {
  type        = string
  description = "The name of the DNS zone"
  default     = "moove-ai"

}

variable "dns_project" {
  type        = string
  description = "The name of the DNS project"
  default     = "moove-systems"

}

variable "load_balancer_description" {
  type        = string
  description = "The description of the load balancer"
  default     = "API Gateway Load Balancer"
}

variable "https_proxy_name" {
  type        = string
  description = "The name of the HTTPS proxy"
}
