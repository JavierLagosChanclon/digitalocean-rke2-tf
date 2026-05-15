resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "${var.rancher_hostname}-ca"
  }
  validity_period_hours = 87600
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

resource "tls_private_key" "rancher" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "rancher" {
  private_key_pem = tls_private_key.rancher.private_key_pem
  subject {
    common_name = var.rancher_hostname
  }
  dns_names = [
    var.rancher_hostname
  ]
}

resource "tls_locally_signed_cert" "rancher" {
  cert_request_pem      = tls_cert_request.rancher.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "null_resource" "rancher_tls_secret" {
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}

echo "Waiting for Kubernetes API..."

until kubectl get nodes >/dev/null 2>&1; do
  sleep 5
done

kubectl create namespace cattle-system --dry-run=client -o yaml | kubectl apply -f -

echo "Applying Rancher TLS secret..."

cat <<CRT | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: tls-rancher-ingress
  namespace: cattle-system
type: kubernetes.io/tls
data:
  tls.crt: $(echo '${base64encode("${tls_locally_signed_cert.rancher.cert_pem}${tls_self_signed_cert.ca.cert_pem}")}')
  tls.key: $(echo '${base64encode(tls_private_key.rancher.private_key_pem)}')
CRT

echo "Applying Rancher CA secret..."

cat <<CA | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: tls-ca
  namespace: cattle-system
type: Opaque
data:
  cacerts.pem: $(echo '${base64encode(tls_self_signed_cert.ca.cert_pem)}')
CA

EOF
  }
  triggers = {
    cert = tls_locally_signed_cert.rancher.cert_pem
    ca   = tls_self_signed_cert.ca.cert_pem
  }
}
