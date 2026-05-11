variable "certmanager_version" {
  description = "Cert-manager Helm chart version. If empty, latest version will be installed. Default is null (latest version)."
  type        = string
  default     = null
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file used by kubectl. Default is null."
  type        = string
  default     = null
}
