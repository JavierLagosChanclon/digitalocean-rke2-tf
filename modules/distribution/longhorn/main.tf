resource "null_resource" "longhorn_dependencies" {
  count = var.longhorn_enabled ? length(var.node_ips) : 0
  connection {
    type        = "ssh"
    user        = "opensuse"
    host        = var.node_ips[count.index]
    private_key = var.ssh_private_key
  }
  provisioner "remote-exec" {
    inline = [
      "sudo zypper -n --gpg-auto-import-keys refresh",
      "sudo zypper -n install open-iscsi nfs-client cryptsetup device-mapper",
      "sudo systemctl enable --now iscsid",
      "sudo modprobe dm-crypt",
      "sudo systemctl stop multipathd || true",
      "sudo systemctl disable multipathd || true",
      "sudo systemctl mask multipathd || true"
    ]
  }
}

resource "helm_release" "longhorn" {
  count            = var.longhorn_enabled ? 1 : 0
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  namespace        = "longhorn-system"
  create_namespace = true
  version          = var.longhorn_version
  depends_on = [
    null_resource.longhorn_dependencies
  ]
  values = [
    <<EOF
defaultSettings:
  deletingConfirmationFlag: true
  storageOverProvisioningPercentage: 300

ingress:
  enabled: true
  ingressClassName: traefik
  host: ${var.longhorn_host}
  tls: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-lab
EOF
  ]
}
