resource "helm_release" "rancher" {
  count            = var.rancher_enabled ? 1 : 0
  name             = "rancher"
  namespace        = "cattle-system"
  repository       = "https://releases.rancher.com/server-charts/stable"
  chart            = "rancher"
  version          = var.rancher_version
  create_namespace = true

  values = [
    <<EOF
hostname: ${var.rancher_hostname}

bootstrapPassword: ${var.rancher_bootstrap_password}

extraEnv:
  - name: CATTLE_SERVER_URL
    value: https://${var.rancher_hostname}

ingress:
  tls:
    source: ${var.rancher_tls_source}

letsEncrypt:
  ingress:
    class: traefik

postDelete:
  enabled: false

agentTLSMode: system-store
EOF
  ]
}
