variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Region where the droplets will be created"
  type        = string
  default     = null
  validation {
    condition = contains(["nyc1", "nyc2", "nyc3", "ams3", "sfo2", "sfo3", "sgp1", "lon1", "fra1", "tor1", "blr1", "syd1"], var.region)
    error_message = "Please, Specify the correct region to deploy nodes on DigitalOcean -> https://slugs.do-api.dev/"
  }
}

variable "size" {
  description = "Droplet size"
  type        = string
  default     = null
}

variable "droplet_count" {
  description = "Number of droplets to create"
  type        = number
  default     = 3
  validation {
    condition = contains([1, 3, 4, 5, 6, 7, 8, 9, 10], var.droplet_count)
    error_message = "Please, Specify number of nodes supported. -> 1, 3, 5, 6, 7, 8, 9 or 10"
  }
}

variable "prefix" {
  description = "prefix name"
  type        = string
  default     = null
}

variable "rke2_version" {
  description = "rke2 installed version"
  type        = string
  default     = ""
}

variable "rke2_token" {
  description = "token used by rke2 server configuration"
  type        = string
  default     = null
  sensitive   = true
}

variable "kubeconfig_path" {
  description = "kubeconfig path"
  type        = string
  default     = null
}

variable "rancher_password" {
  description = "rancher password used to login with admin user in webUI"
  type        = string
  default     = "admin"
}

variable "rancher_version" {
  description = "rancher helm chart version"
  type        = string
  default     = ""
}

variable "neuvector_install" {
  description = "Define if NeuVector is installed or not"
  type        = bool
  default     = false
}

variable "neuvector_version" {
  description = "Neuvector helm chart version"
  type        = string
  default     = ""
}

variable "longhorn_install" {
  description = "Define if longhorn is installed or not"
  type        = bool
  default     = false
}

variable "longhorn_version" {
  description = "Longhorn helm chart version"
  type        = string
  default     = ""
}

variable "stackstate_install" {
  description = "Define if StackState is installed or not"
  type = bool
  default = false
}

variable "stackstate_license" {
  description = "stackstate license used to deploy Suse Observability"
  type = string
  default = ""
}

variable "stackstate_sizing" {
  description = "stackstate size used to deploy Suse Observability"
  type = string
  default = "trial"
  validation {
    condition = contains(["trial", "10-nonha", "20-nonha", "50-nonha", "100-nonha", "150-ha", "250-ha", "500-ha"], var.stackstate_sizing)
    error_message = "Please, specify a valid StackState size. Please see following URL https://docs.stackstate.com/self-hosted-setup/install-stackstate/requirements"
  }
}