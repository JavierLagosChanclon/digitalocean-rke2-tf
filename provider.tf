provider "digitalocean" {
  token = var.do_token
}

provider "helm" {
  alias = "main"
  kubernetes = {
    config_path = "${local.kc_path}/${var.prefix}_kubeconfig.yaml"
  }
}

provider "helm" {
  alias = "downstream"
  kubernetes = {
    config_path = "${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml"
  }
}