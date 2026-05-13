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
  - name: CATTLE_TUNNEL_TIMEOUT
    value: "3600"

ingress:
  tls:
    source: ${var.rancher_tls_source}
  extraAnnotations:
    traefik.ingress.kubernetes.io/proxy-read-timeout: "3600"
    traefik.ingress.kubernetes.io/proxy-send-timeout: "3600"
    traefik.ingress.kubernetes.io/service.serversscheme: "http"

letsEncrypt:
  ingress:
    class: traefik

postDelete:
  enabled: false

agentTLSMode: system-store
EOF
  ]
}
