variable "environment" {
  type        = string
  description = "The environment to deploy these resources to"
}

variable "project_id" {
  type        = string
  description = "The project ID the cluster will be deployed in"
}

variable "cluster_name" {
  type        = string
  description = "The name of the GKE cluster to be created"
}

variable "region" {
  type        = string
  description = "The GCP Region to deploy this module into"
}

variable "cluster_zones" {
  type        = list(string)
  description = "List of zones in the region the cluster should operate in"
}

variable "cluster_subnetwork" {
  type        = string
  description = "The name of the Subnetwork the cluster will run in"
}

variable "cluster_network" {
  type        = string
  description = "The VPC network the cluster is going to run in"
}

variable "cluster_network_project_id" {
  type        = string
  description = "The name of the project the VPC resides in."
}

variable "ip_range_pods" {
  type        = string
  description = "The name of the Secondary Range that pods will default to"
}

variable "ip_range_services" {
  type        = string
  description = "The name of the Secondary Range that services will default to"
}

variable "gce_pd_csi_driver" {
  type        = bool
  description = "Enables the GCE Disk CSI Driver."
  default     = true
}

variable "http_load_balancing" {
  type        = bool
  description = "Enables HTTP Load Balancing"
  default     = true
}

variable "network_policy" {
  type        = bool
  description = "Enables Network Policy"
  default     = true
}

variable "horizontal_pod_autoscaling" {
  type        = bool
  description = "Enables Horizontal Pod Autoscaling"
  default     = true
}

variable "filestore_csi_driver" {
  type        = bool
  description = "Enables the Firestore CSI Driver"
  default     = false
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Enables the Private Endpoint on this cluster"
  default     = true
}

variable "enable_private_nodes" {
  type        = bool
  description = "Enables Private nodes on this cluster"
  default     = true
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The IPv4 CIDR block to give for the cluster."
}

variable "istio" {
  type        = bool
  description = "Enables ISTIO on this cluster"
  default     = false
}

variable "cloudrun" {
  type        = bool
  description = "Enables Cloud Run"
  default     = false
}


variable "dns_cache" {
  type        = bool
  description = "Enables DNS Caching"
  default     = false
}

variable "node_pools" {
  type        = list(map(string))
  description = "List of maps containing node pools"
}

variable "node_pools_oauth_scopes" {
  type        = map(list(string))
  description = "Map of lists containing node oauth scopes by node-pool name"
}

variable "node_pools_labels" {
  type        = map(map(string))
  description = "Map of maps containing node labels by node-pool name"
}

variable "node_pools_metadata" {
  type        = map(map(string))
  description = "Map of maps containing node metadata by node-pool name"
  default = {
    all = {}
  }
}

variable "node_pools_taints" {
  type        = map(list(object({ key = string, value = string, effect = string })))
  description = "Map of lists containing node taints by node-pool name"
}

variable "node_pools_tags" {
  type        = map(list(string))
  description = "Map of lists containing node network tags by node-pool name"
}

variable "remove_default_node_pool" {
  type        = bool
  description = "Removes the default node pool if set"
}

variable "enable_network_egress_export" {
  type        = bool
  description = "Enables network egress billing report"
  default     = true
}

#variable "resource_usage_export_dataset_id" {
#  type = string
#  description = "The name of the BQ dataset ID to store billing report data in"
#}

variable "cluster_labels" {
  type        = map(string)
  description = "Map of label keys and label values to apply to this cluster"
}

variable "proxy_zone" {
  type        = string
  description = "The zone to deploy the GKE proxy service into"
}

variable "proxy_dns" {
  type        = string
  description = "The DNS name of the GKE proxy"
}

variable "image_type" {
  type        = string
  description = "The image type for the cluster"
  default     = "COS_CONTAINERD"
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of networks allowed to access the cluster"
  default = [{
    cidr_block   = "10.80.64.0/20",
    display_name = "mgmt_us-central1"
    }
  ]
}

variable "install_argocd" {
  type        = bool
  description = "Installs helm chart."
  default     = true
}

variable "install_common_resources" {
  type        = bool
  description = "Installs helm chart."
  default     = true
}

variable "install_cert_manager" {
  type        = bool
  description = "Installs helm chart."
  default     = true
}

variable "install_cert_manager_pilot" {
  type        = bool
  description = "Installs helm chart."
  default     = true
}

variable "install_external_dns" {
  type        = bool
  description = "Installs helm chart."
  default     = true
}

variable "install_external_secrets" {
  type        = bool
  description = "Installs helm chart."
  default     = true
}

variable "install_external_secrets_pilot" {
  type        = bool
  description = "Installs helm chart."
  default     = true
}

variable "install_keda" {
  type        = bool
  description = "Set to true to install keda"
  default     = true
}

variable "cluster_autoscaling" {
  type = object({
    enabled             = bool
    autoscaling_profile = string
    min_cpu_cores       = number
    max_cpu_cores       = number
    min_memory_gb       = number
    max_memory_gb       = number
    gpu_resources       = list(object({ resource_type = string, minimum = number, maximum = number }))
  })
  default = {
    enabled             = false
    autoscaling_profile = "BALANCED"
    max_cpu_cores       = 0
    min_cpu_cores       = 0
    max_memory_gb       = 0
    min_memory_gb       = 0
    gpu_resources       = []
  }
  description = "Cluster autoscaling configuration. See [more details](https://cloud.google.com/kubernetes-engine/docs/reference/rest/v1beta1/projects.locations.clusters#clusterautoscaling)"
}

variable "kubernetes_version" {
  type = string
  description = "The version to install on the gke main node"
  default = "latest" 
}