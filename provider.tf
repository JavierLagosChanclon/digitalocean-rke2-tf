provider "digitalocean" {
  token = var.do_token
}

provider "helm" {
  kubernetes {
    config_path = "${local.kc_path}/${var.prefix}_kubeconfig.yaml"
  }
}