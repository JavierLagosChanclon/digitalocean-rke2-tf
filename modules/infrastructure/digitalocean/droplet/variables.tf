variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'do-tf'."
  type        = string
  default     = "do-tf"
}

variable "region" {
  description = "Specifies the DigitalOcean region used for all resources. Default is 'fra1'."
  type        = string
  default     = "fra1"
  validation {
    condition = contains([
      "nyc1",
      "nyc2",
      "nyc3",
      "ams3",
      "sfo2",
      "sfo3",
      "sgp1",
      "lon1",
      "fra1",
      "tor1",
      "blr1",
      "syd1"
    ], var.region)
    error_message = "Invalid Region specified."
  }
}

variable "ssh_key_id" {
  type    = string
  default = null
}

variable "instance_count" {
  description = "Specifies the number of Droplets to create. Default is 1."
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Specifies the name of the DigitalOcean Droplet type. Default is 'g-16vcpu-64gb'."
  type        = string
  default     = "g-16vcpu-64gb"
}

variable "data_disk_count" {
  description = "Specifies the number of additional data disks to attach to each VM instance. Default is 1."
  type        = number
  default     = 1
}

variable "data_disk_size" {
  description = "Specifies the size of each additional data disks attached to the Droplet, in GB. Default is '350'."
  type        = number
  default     = 350
}

variable "image_id" {
  description = "Specifies the ID of the custom OS image used to provision all RKE2 cluster droplets. Defailt is empty."
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Specifies cloud-init user_data used to bootstrap the Droplet. Default is 'null'."
  type        = string
  default     = null
}
