variable "longhorn_enabled" {
  description = "Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is true."
  type        = bool
  default     = false
}

variable "longhorn_host" {
  description = "Specifies the hostname used to expose Longhorn via Ingress (e.g. sslip.io or custom domain). Default is null."
  type        = string
  default     = null
}

variable "node_ips" {
  description = "Specifies the list of node public IP addresses used to prepare Longhorn dependencies on each cluster node."
  type        = list(string)
  default     = []
}

variable "ssh_private_key" {
  description = "Specifies the SSH private key content used to connect to cluster nodes for Longhorn dependency preparation."
  type        = string
  sensitive   = true
}

variable "ssh_user" {
  description = "Specifies the SSH username used to connect to cluster nodes. Default is 'opensuse'."
  type        = string
  default     = "opensuse"
}

variable "longhorn_version" {
  description = "Specifies the Longhorn Helm chart version to install. Default is null (latest version)."
  type        = string
  default     = null
}
