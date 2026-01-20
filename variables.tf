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
    condition     = contains(["nyc1", "nyc2", "nyc3", "ams3", "sfo2", "sfo3", "sgp1", "lon1", "fra1", "tor1", "blr1", "syd1"], var.region)
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
    condition     = contains([1, 3, 4, 5, 6, 7, 8, 9, 10], var.droplet_count)
    error_message = "Please, Specify number of nodes supported. -> 1, 3, 5, 6, 7, 8, 9 or 10"
  }
}

variable "prefix" {
  description = "Prefix name"
  type        = string
  default     = null
}

variable "use_digitalocean_domain" {
  description = "Variable to define whether to use DigitalOcean custom domain or not. If set as false 'sslip.io' domain will be used"
  type        = bool
  default     = false
}

variable "digitalocean_domain" {
  description = "Custom domain you already have on your account"
  type        = string
  default     = null
}

variable "rke2_version" {
  description = "RKE2 installed version"
  type        = string
  default     = ""
}

variable "rke2_ingress" {
  description = "RKE2 ingress deployed (nginx or traefik)"
  type        = string
  default     = "nginx"

  validation {
    condition     = contains(["nginx", "traefik"], var.rke2_ingress)
    error_message = "The ingress selected must be 'nginx' or 'traefik'."
  }
}

variable "rke2_token" {
  description = "Token used by RKE2 server configuration"
  type        = string
  default     = "my-shared-token"
  sensitive   = true
}

variable "kubeconfig_path" {
  description = "Kubeconfig path"
  type        = string
  default     = null
}

variable "rancher_password" {
  description = "Rancher password used to login with admin user in webUI"
  type        = string
  default     = "myrancherpassword123*"
}

variable "rancher_version" {
  description = "Rancher helm chart version"
  type        = string
  default     = ""
}

variable "neuvector_install" {
  description = "Define if NeuVector is installed or not"
  type        = bool
  default     = false
}

variable "neuvector_downstream_install" {
  description = "Define if NeuVector is installed or not on the downstream cluster"
  type        = bool
  default     = false
}

variable "neuvector_version" {
  description = "Neuvector helm chart version"
  type        = string
  default     = ""
}

variable "neuvector_downstream_version" {
  description = "Neuvector helm chart version for downstream installation"
  type        = string
  default     = ""
}

variable "neuvector_external_ingress" {
  description = "Define if external ingress is required or not (by default it will be accessible through Rancher UI)"
  type        = bool
  default     = false
}

variable "neuvector_downstream_external_ingress" {
  description = "Define if external ingress is required or not (by default it will be accessible through Rancher UI)"
  type        = bool
  default     = false
}

variable "longhorn_install" {
  description = "Define if longhorn is installed or not"
  type        = bool
  default     = false
}

variable "longhorn_downstream_install" {
  description = "Define if longhorn is installed or not on the downstream cluster"
  type        = bool
  default     = false
}

variable "longhorn_version" {
  description = "Longhorn helm chart version"
  type        = string
  default     = ""
}

variable "longhorn_downstream_version" {
  description = "Longhorn helm chart version for downstream installation"
  type        = string
  default     = ""
}

variable "stackstate_install" {
  description = "Define if StackState is installed or not"
  type        = bool
  default     = false
}

variable "stackstate_downstream_install" {
  description = "Define if StackState is installed or not"
  type        = bool
  default     = false
}

variable "stackstate_license" {
  description = "Stackstate license used to deploy Suse Observability"
  type        = string
  default     = ""
}

variable "stackstate_downstream_license" {
  description = "Stackstate license used to deploy Suse Observability on downstream cluster"
  type        = string
  default     = ""
}

variable "stackstate_sizing" {
  description = "Stackstate size used to deploy Suse Observability"
  type        = string
  default     = "trial"
  validation {
    condition     = contains(["trial", "10-nonha", "20-nonha", "50-nonha", "100-nonha", "150-ha", "250-ha", "500-ha"], var.stackstate_sizing)
    error_message = "Please, specify a valid StackState size. Please see following URL https://docs.stackstate.com/self-hosted-setup/install-stackstate/requirements"
  }
}

variable "stackstate_downstream_sizing" {
  description = "Stackstate size used to deploy Suse Observability on downstream cluster"
  type        = string
  default     = "trial"
  validation {
    condition     = contains(["trial", "10-nonha", "20-nonha", "50-nonha", "100-nonha", "150-ha", "250-ha", "500-ha"], var.stackstate_downstream_sizing)
    error_message = "Please, specify a valid StackState size. Please see following URL https://docs.stackstate.com/self-hosted-setup/install-stackstate/requirements"
  }
}

variable "stackstate_rancher_oidc" {
  description = "Defined if rancher will be used as OIDC provider on SUSE Observability"
  type        = bool
  default     = false
}

variable "stackstate_downstream_rancher_oidc" {
  description = "Defined if rancher will be used as OIDC provider on SUSE Observability deployed on downstream cluster"
  type        = bool
  default     = false
}

variable "stackstate_create_oltp_ingress" {
  description = "Defined whether OLTP stackstate ingress are required to be deployed or not"
  type        = bool
  default     = false
}

variable "stackstate_downstream_create_oltp_ingress" {
  description = "Defined whether OLTP stackstate ingress are required to be deployed or not on the downstream cluster"
  type        = bool
  default     = false
}

variable "create_downstream_cluster" {
  description = "Variable to define if downstream cluster should be created"
  type        = bool
  default     = false
}

variable "downstream_droplet_count" {
  description = "Number of nodes created in downstream cluster"
  type        = number
  default     = 1
}

variable "downstream_cni" {
  description = "Select CNI that will be installed on downstream cluster"
  type        = string
  default     = "canal"
  validation {
    condition     = contains(["canal", "calico", "flannel"], var.downstream_cni)
    error_message = "Please, specify a valid CNI type for downstream cluster. You can select canal, calico or flannel"
  }
}

variable "downstream_size" {
  description = "Droplet size used by downstream nodes"
  type        = string
  default     = null
}