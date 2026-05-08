variable "node_role" {
  description = "Specifies the RKE2 node role for this instance. Valid values are 'server' or 'agent'. The role determines whether the node participates in the control plane/etcd cluster ('server') or joins as a worker node ('agent'). Default is 'agent'."
  type        = string
  default     = "agent"
  validation {
    condition     = contains(["server", "agent"], var.node_role)
    error_message = "Invalid node_role. Allowed values are 'server' or 'agent'."
  }
}

variable "rke2_token" {
  description = "Specifies the shared token used by all nodes to join the RKE2 cluster. Default is 'null'."
  type        = string
  default     = null
}

variable "rke2_version" {
  description = "Specifies the RKE2 version to install. Default is 'v1.35.4+rke2r1'."
  type        = string
  default     = "v1.35.4+rke2r1"
  validation {
    condition     = can(regex("^v.*$", var.rke2_version))
    error_message = "The RKE2 version must start with 'v'."
  }
}

variable "server_url" {
  description = "Specifies the URL of the first RKE2 server node (required for 'server' and 'agent' roles). Default is 'null'."
  type        = string
  default     = null
}

variable "rke2_config" {
  description = "Specifies additional custom RKE2 configuration in YAML format. Default is empty."
  type        = string
  default     = ""
}

variable "rke2_ingress" {
  description = "Specifies the ingress controller to deploy. Allowed values are 'traefik', 'nginx', or 'none'. Default is 'traefik'."
  type        = string
  default     = "traefik"
  validation {
    condition     = contains(["traefik", "nginx", "none"], var.rke2_ingress)
    error_message = "Invalid ingress controller. Allowed values are 'traefik', 'nginx', or 'none'."
  }
}
