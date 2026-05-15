resource "random_string" "rke2_token" {
  length  = 32
  special = false
}

locals {
  ssh_private_key_path = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path  = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  ssh_username         = "opensuse"
  kubeconfig_file      = "${path.cwd}/${var.prefix}_kubeconfig.yml"
  instance_type        = var.instance_type
  rke2_token           = random_string.rke2_token.result
  first_server_url     = "https://${module.rke2_first_server.instances_public_ip[0]}:9345"
  server_count         = var.instance_count < 3 ? var.instance_count : 3
  server_nodes         = var.instance_count == 1 ? [] : [for i in range(2, local.server_count + 1) : tostring(i)]
  worker_count         = var.instance_count > 3 ? var.instance_count - 3 : 0
  worker_nodes         = [for i in range(1, local.worker_count + 1) : tostring(i)]
}

module "identity" {
  source = "../../../modules/identity/ssh"
  prefix = var.prefix
}

module "os_image" {
  source = "../../../modules/custom-os-image"
  prefix = var.prefix
  region = var.region
}

module "rke2_first" {
  source       = "../../../modules/distribution/rke2"
  node_role    = "server"
  rke2_token   = local.rke2_token
  rke2_version = var.rke2_version
  rke2_ingress = var.rke2_ingress
}

module "rke2_first_server" {
  source         = "../../../modules/infrastructure/digitalocean/droplet"
  prefix         = "${var.prefix}-server-1"
  region         = var.region
  ssh_key_id     = module.identity.ssh_key_id
  instance_type  = local.instance_type
  data_disk_size = var.data_disk_size
  image_id       = module.os_image.image_id
  instance_count = 1
  user_data      = module.rke2_first.user_data
}

module "rke2_additional_servers" {
  source       = "../../../modules/distribution/rke2"
  node_role    = "server"
  rke2_token   = local.rke2_token
  rke2_version = var.rke2_version
  rke2_ingress = var.rke2_ingress
  server_url   = local.first_server_url
}

module "rke2_servers" {
  for_each       = toset(local.server_nodes)
  source         = "../../../modules/infrastructure/digitalocean/droplet"
  prefix         = "${var.prefix}-server-${each.value}"
  region         = var.region
  ssh_key_id     = module.identity.ssh_key_id
  instance_type  = local.instance_type
  data_disk_size = var.data_disk_size
  image_id       = module.os_image.image_id
  instance_count = 1
  user_data      = module.rke2_additional_servers.user_data
}

module "rke2_additional_workers" {
  source       = "../../../modules/distribution/rke2"
  node_role    = "agent"
  rke2_token   = local.rke2_token
  rke2_version = var.rke2_version
  rke2_ingress = var.rke2_ingress
  server_url   = local.first_server_url
}

module "rke2_workers" {
  for_each       = toset(local.worker_nodes)
  source         = "../../../modules/infrastructure/digitalocean/droplet"
  prefix         = "${var.prefix}-worker-${each.value}"
  region         = var.region
  ssh_key_id     = module.identity.ssh_key_id
  instance_type  = local.instance_type
  data_disk_size = var.data_disk_size
  image_id       = module.os_image.image_id
  instance_count = 1
  user_data      = module.rke2_additional_workers.user_data
}

data "local_file" "ssh_private_key" {
  depends_on = [module.rke2_first_server]
  filename   = local.ssh_private_key_path
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [
    module.rke2_servers,
    module.rke2_workers
  ]
  host = module.rke2_first_server.instances_public_ip[0]
  commands = [
    "timeout=600; while [ ! -f /etc/rancher/rke2/rke2.yaml ]; do sleep 5; done",
    "sudo cat /etc/rancher/rke2/rke2.yaml | sed 's/127.0.0.1/${module.rke2_first_server.instances_public_ip[0]}/g'"
  ]
  user        = local.ssh_username
  private_key = data.local_file.ssh_private_key.content
}

resource "local_file" "kubeconfig_yaml" {
  filename        = local.kubeconfig_file
  content         = ssh_resource.retrieve_kubeconfig.result
  file_permission = "0600"
}

provider "kubernetes" {
  config_path = local_file.kubeconfig_yaml.filename
}

provider "helm" {
  kubernetes = {
    config_path = local_file.kubeconfig_yaml.filename
  }
}

module "longhorn" {
  source           = "../../../modules/distribution/longhorn"
  depends_on       = [module.rke2_first_server]
  longhorn_enabled = var.longhorn_enabled
  longhorn_host    = "longhorn.${module.rke2_first_server.instances_public_ip[0]}.sslip.io"
  ssh_private_key  = data.local_file.ssh_private_key.content
  node_ips = concat(
    [module.rke2_first_server.instances_public_ip[0]],
    flatten([for m in module.rke2_servers : m.instances_public_ip]),
    flatten([for m in module.rke2_workers : m.instances_public_ip])
  )
}

module "rancher" {
  source                     = "../../../modules/distribution/rancher"
  depends_on                 = [module.rke2_first_server]
  rancher_enabled            = var.rancher_enabled
  rancher_version            = var.rancher_version
  rancher_hostname           = "rancher.${module.rke2_first_server.instances_public_ip[0]}.sslip.io"
  rancher_bootstrap_password = var.rancher_bootstrap_password
  kubeconfig_path            = local_file.kubeconfig_yaml.filename
}
