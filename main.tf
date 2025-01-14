locals {
  kc_path        = var.kubeconfig_path != null ? var.kubeconfig_path : path.cwd
}
data "digitalocean_ssh_keys" "all_ssh_keys" {}

resource "digitalocean_droplet" "nodes" {
  count  = var.droplet_count
  name   = "node-${var.prefix}-${count.index + 1}"
  region = var.region
  size   = var.size
  image  = "ubuntu-20-04-x64"
  ssh_keys = [
    for key in data.digitalocean_ssh_keys.all_ssh_keys.ssh_keys : key.id
  ]
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = self.ipv4_address
  }
  provisioner "remote-exec" {
    inline = count.index == 0 ? [
      "mkdir -p /etc/rancher/rke2",
      "echo 'token: ${var.rke2_token}' > /etc/rancher/rke2/config.yaml",
      "curl -sfL https://get.rke2.io | sh -",
      "systemctl enable rke2-server.service && systemctl start rke2-server.service",
      "modprobe dm-crypt && apt-get remove multipath-tools -y"
    ] : count.index < 3 ? [
      "mkdir -p /etc/rancher/rke2",
      "echo 'token: ${var.rke2_token}' > /etc/rancher/rke2/config.yaml && echo 'server: https://${digitalocean_droplet.nodes[0].ipv4_address}:9345' >> /etc/rancher/rke2/config.yaml",
      "curl -sfL https://get.rke2.io | sh -",
      "systemctl enable rke2-server.service && systemctl start rke2-server.service",
      "modprobe dm-crypt && apt-get remove multipath-tools -y"
    ] : [
      "mkdir -p /etc/rancher/rke2",
      "echo 'token: ${var.rke2_token}' > /etc/rancher/rke2/config.yaml && echo 'server: https://${digitalocean_droplet.nodes[0].ipv4_address}:9345' >> /etc/rancher/rke2/config.yaml",
      "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=\"agent\" sh -",
      "systemctl enable rke2-agent.service && systemctl start rke2-agent.service",
      "modprobe dm-crypt && apt-get remove multipath-tools -y"
    ]
  }
}

resource "digitalocean_loadbalancer" "rke2_lb" {
  name   = "loadbalancer-${var.prefix}"
  region = var.region

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"
    target_port    = 80
    target_protocol = "http"
    tls_passthrough = false
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"
    target_port    = 443
    target_protocol = "https"
    tls_passthrough = true
  }

  healthcheck {
    protocol               = "https"
    port                   = 443
    path                   = "/healthz"
    check_interval_seconds = 5
    response_timeout_seconds = 10
    healthy_threshold      = 3
    unhealthy_threshold    = 3
  }

  droplet_ids = digitalocean_droplet.nodes.*.id

  redirect_http_to_https = true
  enable_backend_keepalive = false
}

resource "null_resource" "modify_kubeconfig" {
  depends_on = [digitalocean_loadbalancer.rke2_lb]
  provisioner "local-exec" {
    command = <<EOF
      scp -o  StrictHostKeyChecking=no -i ${var.ssh_private_key_path} root@${digitalocean_droplet.nodes[0].ipv4_address}:/etc/rancher/rke2/rke2.yaml ${local.kc_path}/${var.prefix}_kubeconfig.yaml
      sed -i '' 's/server: https:\/\/127.0.0.1:6443/server: https:\/\/${digitalocean_droplet.nodes[0].ipv4_address}:6443/g' ${local.kc_path}/${var.prefix}_kubeconfig.yaml
    EOF
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = digitalocean_droplet.nodes[0].ipv4_address
  }
}

resource "null_resource" "wait_for_kubernetes" {
  depends_on = [null_resource.modify_kubeconfig]

  provisioner "local-exec" {
    command = <<EOF
    while ! kubectl --kubeconfig=${local.kc_path}/${var.prefix}_kubeconfig.yaml get nodes >/dev/null 2>&1; do
      echo "Waiting for Kubernetes API to be ready before proceeding with helm installations..."
      sleep 10s
    done
    echo "Kubernetes API is ready!"
    if [ "${var.longhorn_install}" = "true" ]; then
      echo "Applying Longhorn NFS prerequisite installation..."
      kubectl --kubeconfig=${local.kc_path}/${var.prefix}_kubeconfig.yaml create ns longhorn-system && kubectl apply --kubeconfig=${local.kc_path}/${var.prefix}_kubeconfig.yaml -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/prerequisite/longhorn-nfs-installation.yaml -n longhorn-system
    fi
    EOF
  }
}

resource "helm_release" "longhorn" {
  count      = var.longhorn_install ? 1 : 0
  name             = "longhorn"
  chart            = "longhorn"
  namespace        = "longhorn-system"
  repository       = "https://charts.longhorn.io"
  version = var.longhorn_version != "" ? var.longhorn_version : null
  create_namespace = true
  depends_on = [null_resource.wait_for_kubernetes]
  values = [
    <<EOF
defaultSettings:
  deletingConfirmationFlag: true
EOF
  ]
}


resource "helm_release" "cert-manager" {
  name       = "jetstack"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  create_namespace = true
  depends_on = [null_resource.wait_for_kubernetes]
  values = [
    <<EOF
crds:
  enabled: true
EOF
  ]
}

resource "helm_release" "rancher" {
  name       = "rancher"
  chart      = "rancher"
  namespace  = "cattle-system"
  repository = "https://releases.rancher.com/server-charts/latest"
  version = var.rancher_version != "" ? var.rancher_version : null
  create_namespace = true
  depends_on = [helm_release.cert-manager]
  values = [
    <<EOF
hostname: rancher.${digitalocean_loadbalancer.rke2_lb.ip}.sslip.io
bootstrapPassword: ${var.rancher_password}
ingress:
  tls:
    source: letsEncrypt
letsEncrypt:
  ingress:
    class: nginx
EOF
  ]
}

resource "null_resource" "create_cluster_issuer" {
  depends_on = [helm_release.cert-manager]
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
      kubectl apply -f - <<EOF
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-prod
      spec:
        acme:
          server: https://acme-v02.api.letsencrypt.org/directory
          privateKeySecretRef:
            name: letsencrypt-prod
          solvers:
          - http01:
              ingress:
                class: nginx
      EOF
    EOT
  }
}

resource "helm_release" "neuvector-core" {
  count      = var.neuvector_install ? 1 : 0
  name       = "neuvector"
  chart      = "core"
  namespace  = "neuvector"
  repository = "https://neuvector.github.io/neuvector-helm/"
  version = var.neuvector_version != "" ? var.neuvector_version : null
  create_namespace = true
  depends_on = [null_resource.create_cluster_issuer]
  values = [
    <<EOF
controller:
  pvc:
    enabled: ${var.longhorn_install ? "true" : "false"}
    storageClass: null
    accessModes:
      - ReadWriteMany
    capacity: 30Gi
  federation:
    mastersvc:
      type: NodePort
  apisvc:
    type: ClusterIP
cve:
  scanner:
    replicas: 3
manager:
  svc:
    type: ClusterIP
  ingress:
    enabled: true
    tls: true
    secretName: neuvector-tls-secret
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      cert-manager.io/cluster-issuer: letsencrypt-prod
    host: neuvector.${digitalocean_loadbalancer.rke2_lb.ip}.sslip.io
EOF
  ]
}

resource "local_file" "observability_ingress_values" {
  count = var.longhorn_install && var.stackstate_install && var.stackstate_license != null ? 1 : 0
  depends_on = [helm_release.neuvector-core]
  content = templatefile("${path.cwd}/suse-observability-values/templates/ingress_values.tpl", {
    baseUrl         = "observability.${digitalocean_loadbalancer.rke2_lb.ip}.sslip.io"
  })
  filename = "${path.cwd}/suse-observability-values/templates/ingress_values.yaml"
}

resource "null_resource" "suse_observability_template" {
  count = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" ? 1 : 0
  depends_on = [helm_release.neuvector-core]
  provisioner "local-exec" {
    command = <<EOT
      helm repo add suse-observability https://charts.rancher.com/server-charts/prime/suse-observability
      helm template --set license='${var.stackstate_license}' --set baseUrl='https://observability.${digitalocean_loadbalancer.rke2_lb.ip}.sslip.io' --set sizing.profile='${var.stackstate_sizing}' suse-observability-values suse-observability/suse-observability-values --output-dir .
      cat ${path.cwd}/suse-observability-values/templates/baseConfig_values.yaml| grep "Observability admin password" | awk '{print $8}' > ${path.cwd}/suse-observability-values/templates/suse_observability_password.txt
      helm --kubeconfig ${local.kc_path}/${var.prefix}_kubeconfig.yaml upgrade --install suse-observability suse-observability/suse-observability --namespace suse-observability --values ${path.cwd}/suse-observability-values/templates/baseConfig_values.yaml --values ${path.cwd}/suse-observability-values/templates/sizing_values.yaml --values ${path.cwd}/suse-observability-values/templates/ingress_values.yaml --create-namespace
    EOT
  }
}