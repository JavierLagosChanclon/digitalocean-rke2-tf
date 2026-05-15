variable "rancher_enabled" {
  description = "Specifies whether Rancher should be installed on the Kubernetes cluster. Default is false."
  type        = bool
  default     = false
}

variable "rancher_version" {
  description = "Specifies the Rancher Helm chart version to install. Default is null (latest version)."
  type        = string
  default     = null
}

variable "rancher_hostname" {
  description = "Specifies the hostname used to expose Rancher via Ingress."
  type        = string
}

variable "rancher_bootstrap_password" {
  description = "Specifies the bootstrap administrator password used during Rancher installation. Must be at least 12 characters when Rancher is enabled."
  type        = string
  default     = null
  sensitive   = true
  validation {
    condition = (
      var.rancher_enabled == false ||
      (
        var.rancher_bootstrap_password != null &&
        length(var.rancher_bootstrap_password) >= 12
      )
    )
    error_message = "When rancher_enabled is true, rancher_bootstrap_password must be specified and contain at least 12 characters."
  }
}

variable "rancher_tls_source" {
  description = "Specifies the TLS certificate source used by Rancher. Default is 'letsEncrypt'."
  type        = string
  default     = "letsEncrypt"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file used by kubectl. Default is null."
  type        = string
  default     = null
}
