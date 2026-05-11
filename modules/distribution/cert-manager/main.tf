resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.certmanager_version
  create_namespace = true
  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]
  wait    = true
  timeout = 600
}

resource "null_resource" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]
  provisioner "local-exec" {
    command = <<EOT
export KUBECONFIG=${var.kubeconfig_path}

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-lab
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-lab
    solvers:
    - http01:
        ingress:
          class: traefik
EOF
EOT
  }
}
