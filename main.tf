locals {
  kc_path                 = var.kubeconfig_path != null ? var.kubeconfig_path : path.cwd
  domain_url              = var.use_digitalocean_domain ? "${var.prefix}-upstream-${random_string.prefix.result}.${var.digitalocean_domain}" : "${digitalocean_loadbalancer.rke2_lb.ip}.sslip.io"
  domain_downstream_url   = var.create_downstream_cluster ? (var.use_digitalocean_domain ? "${var.prefix}-downstream-${random_string.prefix.result}.${var.digitalocean_domain}" : "${digitalocean_loadbalancer.downstream_rke2_lb[0].ip}.sslip.io") : null
  rke2_version            = var.rke2_version != "" ? var.rke2_version : ""
  rke2_ingress            = var.rke2_ingress == "traefik" ? "traefik" : "ingress-${var.rke2_ingress}"
  ssh_private_key_path    = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path     = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  downstream_prefix       = "${var.prefix}-downstream"
  downstream_rke2_version = var.rke2_version != "" ? var.rke2_version : data.external.upstream_rke2_version.result.version
  registration_command    = [for i in sort(keys(data.external.obtain_registration_command)) : data.external.obtain_registration_command[i].result.command]
}

resource "random_string" "prefix" {
  length  = 4
  upper   = false
  special = false
}


resource "tls_private_key" "ssh_private_key" {
  algorithm = "ED25519"
}

resource "local_file" "private_key_pem" {
  filename        = local.ssh_private_key_path
  content         = tls_private_key.ssh_private_key.private_key_openssh
  file_permission = "0600"
}

resource "local_file" "public_key_pem" {
  filename        = local.ssh_public_key_path
  content         = tls_private_key.ssh_private_key.public_key_openssh
  file_permission = "0600"
}

resource "digitalocean_ssh_key" "do_pub_created_ssh" {
  name       = "${var.prefix}-pub"
  public_key = tls_private_key.ssh_private_key.public_key_openssh
}

resource "digitalocean_droplet" "nodes" {
  count    = var.droplet_count
  name     = "node-${var.prefix}-${count.index + 1}"
  tags     = ["user:${var.prefix}"]
  region   = var.region
  size     = var.size
  image    = "ubuntu-24-04-x64"
  ssh_keys = [digitalocean_ssh_key.do_pub_created_ssh.id]
  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.ssh_private_key.private_key_openssh
    host        = self.ipv4_address
  }
  provisioner "remote-exec" {
    inline = count.index == 0 ? [
      "mkdir -p /etc/rancher/rke2",
      "echo 'token: ${var.rke2_token}' > /etc/rancher/rke2/config.yaml && echo 'ingress-controller: ${local.rke2_ingress}' >> /etc/rancher/rke2/config.yaml",
      "curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${local.rke2_version} sh -",
      "systemctl enable rke2-server.service && systemctl start rke2-server.service"
      ] : count.index < 3 ? [
      "mkdir -p /etc/rancher/rke2",
      "echo 'token: ${var.rke2_token}' > /etc/rancher/rke2/config.yaml && echo 'server: https://${digitalocean_droplet.nodes[0].ipv4_address}:9345' >> /etc/rancher/rke2/config.yaml && echo 'ingress-controller: ${local.rke2_ingress}' >> /etc/rancher/rke2/config.yaml",
      "curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${local.rke2_version} sh -",
      "systemctl enable rke2-server.service && systemctl start rke2-server.service"
      ] : [
      "mkdir -p /etc/rancher/rke2",
      "echo 'token: ${var.rke2_token}' > /etc/rancher/rke2/config.yaml && echo 'server: https://${digitalocean_droplet.nodes[0].ipv4_address}:9345' >> /etc/rancher/rke2/config.yaml && echo 'ingress-controller: ${local.rke2_ingress}' >> /etc/rancher/rke2/config.yaml",
      "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=\"agent\" INSTALL_RKE2_VERSION=${local.rke2_version} sh -",
      "systemctl enable rke2-agent.service && systemctl start rke2-agent.service"
    ]
  }
}

resource "null_resource" "rke2_nginx_ingress_config" {
  depends_on = [digitalocean_droplet.nodes]
  count = var.rke2_ingress == "nginx" ? 1 : 0
  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.ssh_private_key.private_key_openssh
    host        = digitalocean_droplet.nodes[0].ipv4_address
  }
  provisioner "file" {
    source      = "${path.module}/files/rke2-ingress-nginx-config.yaml"
    destination = "/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml"
  }
}

resource "digitalocean_loadbalancer" "rke2_lb" {
  name   = "loadbalancer-${var.prefix}"
  region = var.region

  forwarding_rule {
    entry_port      = 80
    entry_protocol  = "http"
    target_port     = 80
    target_protocol = "http"
    tls_passthrough = false
  }

  forwarding_rule {
    entry_port      = 443
    entry_protocol  = "https"
    target_port     = 443
    target_protocol = "https"
    tls_passthrough = true
  }

  healthcheck {
    protocol                 = var.rke2_ingress == "nginx" ? "https" : "tcp"
    port                     = 443
    path                     = var.rke2_ingress == "nginx" ? "/healthz" : null
    check_interval_seconds   = 5
    response_timeout_seconds = 10
    healthy_threshold        = 3
    unhealthy_threshold      = 3
  }

  droplet_ids = digitalocean_droplet.nodes.*.id

  redirect_http_to_https   = true
  enable_backend_keepalive = false
}

resource "digitalocean_record" "www" {
  count  = var.use_digitalocean_domain ? 1 : 0
  domain = var.digitalocean_domain
  type   = "A"
  name   = "*.${var.prefix}-upstream-${random_string.prefix.result}"
  value  = digitalocean_loadbalancer.rke2_lb.ip
}

resource "null_resource" "modify_kubeconfig" {
  depends_on = [digitalocean_loadbalancer.rke2_lb]
  provisioner "local-exec" {
    command = <<EOF
      scp -o  StrictHostKeyChecking=no -i ${local.ssh_private_key_path} root@${digitalocean_droplet.nodes[0].ipv4_address}:/etc/rancher/rke2/rke2.yaml ${local.kc_path}/${var.prefix}_kubeconfig.yaml
      sed -i.bak "s|server: https://127.0.0.1:6443|server: https://${digitalocean_droplet.nodes[0].ipv4_address}:6443|g" "${local.kc_path}/${var.prefix}_kubeconfig.yaml"
      rm ${local.kc_path}/${var.prefix}_kubeconfig.yaml.bak
    EOF
  }
}

resource "null_resource" "longhorn_dependency" {
  count      = var.longhorn_install ? var.droplet_count : 0
  depends_on = [digitalocean_loadbalancer.rke2_lb]
  provisioner "remote-exec" {
    inline = [
      "modprobe dm-crypt && systemctl stop multipathd  && systemctl disable multipathd && systemctl mask multipathd"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.ssh_private_key.private_key_openssh
      host        = digitalocean_droplet.nodes[count.index].ipv4_address
    }
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
      kubectl --kubeconfig=${local.kc_path}/${var.prefix}_kubeconfig.yaml create ns longhorn-system && kubectl apply --kubeconfig=${local.kc_path}/${var.prefix}_kubeconfig.yaml -f https://raw.githubusercontent.com/longhorn/longhorn/v1.8.0/deploy/prerequisite/longhorn-nfs-installation.yaml -n longhorn-system
      echo "Waiting until NFS installation is completed on all nodes"
      kubectl --kubeconfig=${local.kc_path}/${var.prefix}_kubeconfig.yaml wait --for condition=ready pod -l app=longhorn-nfs-installation -n longhorn-system --timeout 900s
    fi
    EOF
  }
}

resource "helm_release" "longhorn" {
  count            = var.longhorn_install ? 1 : 0
  provider         = helm.main
  name             = "longhorn"
  chart            = "longhorn"
  namespace        = "longhorn-system"
  repository       = "https://charts.longhorn.io"
  version          = var.longhorn_version != "" ? var.longhorn_version : null
  create_namespace = true
  depends_on       = [null_resource.wait_for_kubernetes]
  values = [
    <<EOF
defaultSettings:
  deletingConfirmationFlag: true
  storageOverProvisioningPercentage: 300
EOF
  ]
}


resource "helm_release" "cert-manager" {
  provider         = helm.main
  name             = "jetstack"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  create_namespace = true
  depends_on       = [null_resource.wait_for_kubernetes]
  values = [
    <<EOF
crds:
  enabled: true
EOF
  ]
}

resource "helm_release" "rancher" {
  provider         = helm.main
  name             = "rancher"
  chart            = "rancher"
  namespace        = "cattle-system"
  repository       = "https://charts.rancher.com/server-charts/prime"
  version          = var.rancher_version != "" ? var.rancher_version : null
  create_namespace = true
  depends_on       = [helm_release.cert-manager]
  values = [
    <<EOF
hostname: rancher.${local.domain_url}
bootstrapPassword: ${var.rancher_password}
extraEnv:
  - name: CATTLE_SERVER_URL
    value: https://rancher.${local.domain_url}
ingress:
  tls:
    source: letsEncrypt
letsEncrypt:
  ingress:
    class: ${var.rke2_ingress}
postDelete:
  enabled: false
agentTLSMode: system-store
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
                class: ${var.rke2_ingress}
      EOF
    EOT
  }
}

resource "helm_release" "neuvector-core" {
  count            = var.neuvector_install ? 1 : 0
  provider         = helm.main
  name             = "neuvector"
  chart            = "core"
  namespace        = "cattle-neuvector-system"
  repository       = "https://neuvector.github.io/neuvector-helm/"
  version          = var.neuvector_version != "" ? var.neuvector_version : null
  create_namespace = true
  depends_on       = [null_resource.create_cluster_issuer]
  values = [
    <<EOF
global:
  cattle:
    url: https://rancher.${local.domain_url}
controller:
  ranchersso:
    enabled: true
  pvc:
    enabled: ${var.longhorn_install ? "true" : "false"}
    storageClass: null
    accessModes:
      - ReadWriteMany
    capacity: 30Gi
  federation:
    mastersvc:
      type: NodePort
      nodePort: 32045
    managedsvc:
      type: NodePort
      nodePort: 32046
  apisvc:
    type: ClusterIP
cve:
  scanner:
    replicas: 3
manager:
  svc:
    type: ClusterIP
    annotations:
      traefik.ingress.kubernetes.io/service.serversscheme: https
      traefik.ingress.kubernetes.io/service.serverstransport: cattle-neuvector-system-neuvector@kubernetescrd
  ingress:
    enabled:  ${var.neuvector_external_ingress ? "true" : "false"}
    tls: true
    secretName: neuvector-tls-secret
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      cert-manager.io/cluster-issuer: letsencrypt-prod
    host: neuvector.${local.domain_url}
EOF
  ]
}

resource "null_resource" "create_neuvector_traefik" {
  depends_on = [helm_release.neuvector-core]
  count = var.rke2_ingress == "traefik" && var.neuvector_install ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
      kubectl apply -f - <<EOF
      apiVersion: traefik.io/v1alpha1
      kind: ServersTransport
      metadata:
        name: neuvector
        namespace: cattle-neuvector-system
      spec:
        insecureSkipVerify: true
      EOF
    EOT
  }
}

resource "local_file" "observability_ingress_values" {
  count      = var.longhorn_install && var.stackstate_install && var.stackstate_license != null ? 1 : 0
  depends_on = [null_resource.create_cluster_issuer]
  content = templatefile("${path.cwd}/suse-observability-values/templates/ingress_values.tpl", {
    baseUrl         = "observability.${local.domain_url}"
    stackstate_otlp = var.stackstate_create_oltp_ingress
  })
  filename = "${path.cwd}/suse-observability-values/templates/ingress_values.yaml"
}

resource "null_resource" "create_suse_observability_rancher_oidc" {
  count      = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" && var.stackstate_rancher_oidc ? 1 : 0
  depends_on = [helm_release.rancher]
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
      until kubectl get crd oidcclients.management.cattle.io > /dev/null 2>&1 ; do echo "OIDCClient crd is not ready yet, sleeping 10s" && sleep 10s; done
      kubectl apply -f - <<EOF
      apiVersion: management.cattle.io/v3
      kind: OIDCClient
      metadata:
        name: oidc-observability
      spec:
        tokenExpirationSeconds: 600
        refreshTokenExpirationSeconds: 3600
        redirectURIs:
          - "https://observability.${local.domain_url}/loginCallback?client_name=StsOidcClient"
      EOF
    EOT
  }
}

data "external" "suse_observability_oidc_rancher" {
  count      = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" && var.stackstate_rancher_oidc ? 1 : 0
  depends_on = [null_resource.create_suse_observability_rancher_oidc]
  program = ["bash", "-c", <<EOT
    export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
    CLIENT_ID=$(kubectl get oidcclients.management.cattle.io oidc-observability -o jsonpath='{.status.clientID}')
    CLIENT_SECRET=$(kubectl get secret $CLIENT_ID -n cattle-oidc-client-secrets -o jsonpath='{.data.client-secret-1}' | base64 -d)
    echo "{\"client_id\": \"$CLIENT_ID\", \"client_secret\": \"$CLIENT_SECRET\"}"
  EOT
  ]
}

resource "local_file" "observability_rancher_oidc_values" {
  count      = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" && var.stackstate_rancher_oidc ? 1 : 0
  depends_on = [data.external.suse_observability_oidc_rancher]
  content = templatefile("${path.cwd}/suse-observability-values/templates/rancher-oidc.tpl", {
    baseUrl       = "https://rancher.${local.domain_url}"
    client_id     = data.external.suse_observability_oidc_rancher[0].result.client_id
    client_secret = data.external.suse_observability_oidc_rancher[0].result.client_secret
  })
  filename = "${path.cwd}/suse-observability-values/templates/rancher-oidc.yaml"
}

resource "null_resource" "suse_observability_template" {
  count      = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" ? 1 : 0
  depends_on = [null_resource.create_cluster_issuer, local_file.observability_rancher_oidc_values]
  provisioner "local-exec" {
    command = <<EOT
    helm repo add suse-observability https://charts.rancher.com/server-charts/prime/suse-observability
    helm repo update
    helm template --set license='${var.stackstate_license}' --set baseUrl='https://observability.${local.domain_url}' --set rancherUrl='https://rancher.${local.domain_url}' --set sizing.profile='${var.stackstate_sizing}' suse-observability-values suse-observability/suse-observability-values --output-dir .
    helm --kubeconfig ${local.kc_path}/${var.prefix}_kubeconfig.yaml upgrade --install suse-observability suse-observability/suse-observability --namespace suse-observability --values ${path.cwd}/suse-observability-values/templates/baseConfig_values.yaml --values ${path.cwd}/suse-observability-values/templates/sizing_values.yaml --values ${path.cwd}/suse-observability-values/templates/ingress_values.yaml ${var.stackstate_rancher_oidc ? "--values ${path.cwd}/suse-observability-values/templates/rancher-oidc.yaml" : ""} ${var.rke2_ingress == "traefik" ? "--values ${path.cwd}/suse-observability-values/templates/otel-collector-values.yaml" : ""} --create-namespace
    EOT
  }
}

data "external" "suse_observability_password" {
  count      = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" && !var.stackstate_rancher_oidc ? 1 : 0
  depends_on = [null_resource.suse_observability_template]
  program = ["bash", "-c", <<EOT
    PASSWORD=$(cat suse-observability-values/templates/baseConfig_values.yaml | grep "Observability admin password" | awk '{print $8}')
    echo "{\"password\": \"$PASSWORD\"}"
  EOT
  ]
}

data "external" "upstream_rke2_version" {
  depends_on = [null_resource.wait_for_kubernetes]
  program = ["bash", "-c", <<EOT
    export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
    RKE2_VERSION=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
    echo "{\"version\": \"$RKE2_VERSION\"}"
  EOT
  ]
}

resource "null_resource" "create_downstream_cluster" {
  count      = var.create_downstream_cluster ? 1 : 0
  depends_on = [helm_release.rancher]
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
      while true; do if kubectl rollout status -w -n cattle-capi-system deploy/capi-controller-manager &> /dev/null; then echo "CAPI pods are ready in cattle-capi-system" && break; elif kubectl rollout status -w -n cattle-provisioning-capi-system deploy/capi-controller-manager &> /dev/null; then echo "CAPI pods are ready in cattle-provisioning-capi-system" && break; else echo "Waiting for CAPI pods to be ready... Retrying in 5s" && sleep 5; fi; done && sleep 30s
      kubectl apply -f - <<EOF
      apiVersion: provisioning.cattle.io/v1
      kind: Cluster
      metadata:
        name: ${local.downstream_prefix}
        namespace: fleet-default
      spec:
        kubernetesVersion: ${local.downstream_rke2_version}
        rkeConfig:
          machineGlobalConfig:
            cni: ${var.downstream_cni}
      EOF
    EOT
  }
}

resource "null_resource" "create_downstream_registration_token" {
  for_each   = var.create_downstream_cluster ? toset([for i in range(var.downstream_droplet_count) : tostring(i)]) : toset([])
  depends_on = [null_resource.create_downstream_cluster]
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
      CLUSTERID=$(kubectl get clusters.provisioning.cattle.io -n fleet-default -o json | jq -r '.items[] | select(.metadata.name == "${local.downstream_prefix}") | .status.clusterName')
      kubectl apply -f - <<EOF
      apiVersion: management.cattle.io/v3
      kind: ClusterRegistrationToken
      metadata:
        name: ${local.downstream_prefix}-${each.key}
        namespace: $CLUSTERID
      spec:
        clusterName: $CLUSTERID
      EOF
    EOT
  }
}

data "external" "obtain_registration_command" {
  for_each   = var.create_downstream_cluster ? toset([for i in range(var.downstream_droplet_count) : tostring(i)]) : toset([])
  depends_on = [null_resource.create_downstream_registration_token]
  program = ["bash", "-c", <<EOT
    export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
    CLUSTERID=$(kubectl get clusters.provisioning.cattle.io -n fleet-default -o json | jq -r '.items[] | select(.metadata.name == "${local.downstream_prefix}") | .status.clusterName')
    TOKEN_NAME=${local.downstream_prefix}-${each.key}
    COMMAND=$(kubectl get clusterregistrationtokens.management.cattle.io -n $CLUSTERID $TOKEN_NAME -o jsonpath='{.status.insecureNodeCommand}')
    echo "{\"command\": \"$COMMAND\"}"
  EOT
  ]
}


resource "digitalocean_droplet" "downstream_nodes" {
  depends_on = [data.external.obtain_registration_command]
  count      = var.create_downstream_cluster ? var.downstream_droplet_count : 0
  name       = "node-${local.downstream_prefix}-${count.index + 1}"
  tags       = ["user:${var.prefix}"]
  region     = var.region
  size       = var.downstream_size
  image      = "ubuntu-24-04-x64"
  ssh_keys   = [digitalocean_ssh_key.do_pub_created_ssh.id]
  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.ssh_private_key.private_key_openssh
    host        = self.ipv4_address
  }
  provisioner "remote-exec" {
    inline = [
      "${local.registration_command[count.index]} --etcd --controlplane --worker",
      "modprobe dm-crypt && systemctl stop multipathd  && systemctl disable multipathd && systemctl mask multipathd",
      "until systemctl is-active --quiet rke2-server; do echo 'rke2 service is still not active, sleeping 30s'&& sleep 30s; done"
    ]
  }
}

resource "null_resource" "rke2_nginx_downstream_ingress_config" {
  count      = var.create_downstream_cluster ? 1 : 0
  depends_on = [digitalocean_droplet.downstream_nodes]
  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.ssh_private_key.private_key_openssh
    host        = digitalocean_droplet.downstream_nodes[0].ipv4_address
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /var/lib/rancher/rke2/server/manifests"
    ]
  }
  provisioner "file" {
    source      = "${path.cwd}/files/rke2-ingress-nginx-config.yaml"
    destination = "/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml"
  }
}

resource "digitalocean_loadbalancer" "downstream_rke2_lb" {
  count  = var.create_downstream_cluster ? 1 : 0
  name   = "loadbalancer-${local.downstream_prefix}"
  region = var.region

  forwarding_rule {
    entry_port      = 80
    entry_protocol  = "http"
    target_port     = 80
    target_protocol = "http"
    tls_passthrough = false
  }

  forwarding_rule {
    entry_port      = 443
    entry_protocol  = "https"
    target_port     = 443
    target_protocol = "https"
    tls_passthrough = true
  }

  healthcheck {
    protocol                 = "https"
    port                     = 443
    path                     = "/healthz"
    check_interval_seconds   = 5
    response_timeout_seconds = 10
    healthy_threshold        = 3
    unhealthy_threshold      = 3
  }

  droplet_ids = digitalocean_droplet.downstream_nodes.*.id

  redirect_http_to_https   = true
  enable_backend_keepalive = false
}

resource "null_resource" "downstream_kubeconfig" {
  depends_on = [digitalocean_loadbalancer.downstream_rke2_lb]
  count      = var.create_downstream_cluster ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
      scp -o  StrictHostKeyChecking=no -i ${local.ssh_private_key_path} root@${digitalocean_droplet.downstream_nodes[0].ipv4_address}:/etc/rancher/rke2/rke2.yaml ${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml
      sed -i.bak "s|server: https://127.0.0.1:6443|server: https://${digitalocean_droplet.downstream_nodes[0].ipv4_address}:6443|g" "${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml"
      rm ${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml.bak
    EOF
  }
}

resource "null_resource" "wait_for_kubernetes_downstream" {
  depends_on = [null_resource.downstream_kubeconfig]
  count      = var.create_downstream_cluster ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
    while ! kubectl --kubeconfig=${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml get nodes >/dev/null 2>&1; do
      echo "Waiting for Kubernetes API to be ready before proceeding with helm installations..."
      sleep 10s
    done
    echo "Kubernetes API is ready!"
    if [ "${var.longhorn_downstream_install}" = "true" ]; then
      echo "Applying Longhorn NFS prerequisite installation..."
      kubectl --kubeconfig=${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml create ns longhorn-system && kubectl apply --kubeconfig=${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml -f https://raw.githubusercontent.com/longhorn/longhorn/v1.8.0/deploy/prerequisite/longhorn-nfs-installation.yaml -n longhorn-system
      echo "Waiting until NFS installation is completed on all nodes"
      kubectl --kubeconfig=${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml wait --for condition=ready pod -l app=longhorn-nfs-installation -n longhorn-system --timeout 900s
    fi
    EOF
  }
}

resource "digitalocean_record" "www_downstream" {
  count  = var.use_digitalocean_domain && var.create_downstream_cluster ? 1 : 0
  domain = var.digitalocean_domain
  type   = "A"
  name   = "*.${local.downstream_prefix}-${random_string.prefix.result}"
  value  = digitalocean_loadbalancer.downstream_rke2_lb[0].ip
}

resource "helm_release" "longhorn_downstream" {
  depends_on       = [null_resource.wait_for_kubernetes_downstream]
  count            = var.longhorn_downstream_install && var.create_downstream_cluster ? 1 : 0
  provider         = helm.downstream
  name             = "longhorn"
  chart            = "longhorn"
  namespace        = "longhorn-system"
  repository       = "https://charts.longhorn.io"
  version          = var.longhorn_downstream_version != "" ? var.longhorn_downstream_version : null
  create_namespace = true
  values = [
    <<EOF
defaultSettings:
  deletingConfirmationFlag: true
  storageOverProvisioningPercentage: 300
EOF
  ]
}


resource "helm_release" "cert-manager_downstream" {
  count            = var.create_downstream_cluster ? 1 : 0
  provider         = helm.downstream
  name             = "jetstack"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  create_namespace = true
  depends_on       = [null_resource.wait_for_kubernetes_downstream]
  values = [
    <<EOF
crds:
  enabled: true
EOF
  ]
}

resource "null_resource" "create_downstream_cluster_issuer" {
  depends_on = [helm_release.cert-manager_downstream]
  count      = var.create_downstream_cluster ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml
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

resource "helm_release" "neuvector-core_downstream" {
  count            = var.neuvector_downstream_install && var.create_downstream_cluster ? 1 : 0
  provider         = helm.downstream
  name             = "neuvector"
  chart            = "core"
  namespace        = "cattle-neuvector-system"
  repository       = "https://neuvector.github.io/neuvector-helm/"
  version          = var.neuvector_downstream_version != "" ? var.neuvector_downstream_version : null
  create_namespace = true
  depends_on       = [null_resource.create_downstream_cluster_issuer]
  values = [
    <<EOF
global:
  cattle:
    url: https://rancher.${local.domain_url}
controller:
  ranchersso:
    enabled: true
  pvc:
    enabled: ${var.longhorn_downstream_install ? "true" : "false"}
    storageClass: null
    accessModes:
      - ReadWriteMany
    capacity: 30Gi
  federation:
    mastersvc:
      type: NodePort
      nodePort: 32045
    managedsvc:
      type: NodePort
      nodePort: 32046
  apisvc:
    type: ClusterIP
cve:
  scanner:
    replicas: 3
manager:
  svc:
    type: ClusterIP
  ingress:
    enabled: ${var.neuvector_downstream_external_ingress ? "true" : "false"}
    tls: true
    secretName: neuvector-tls-secret
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      cert-manager.io/cluster-issuer: letsencrypt-prod
    host: neuvector.${local.domain_downstream_url}
EOF
  ]
}

resource "local_file" "observability_downstream_ingress_values" {
  count      = var.longhorn_downstream_install && var.stackstate_downstream_install && var.stackstate_downstream_license != null && var.create_downstream_cluster ? 1 : 0
  depends_on = [null_resource.create_downstream_cluster_issuer]
  content = templatefile("${path.cwd}/suse-observability-values/templates/ingress_values.tpl", {
    baseUrl         = "observability.${local.domain_downstream_url}"
    stackstate_otlp = var.stackstate_downstream_create_oltp_ingress
  })
  filename = "${path.cwd}/suse-observability-values/templates/ingress_values.yaml"
}

resource "null_resource" "create_suse_observability_downstream_rancher_oidc" {
  count      = var.longhorn_downstream_install && var.stackstate_downstream_install && var.stackstate_downstream_license != "" && var.stackstate_downstream_rancher_oidc && var.create_downstream_cluster ? 1 : 0
  depends_on = [local_file.observability_downstream_ingress_values]
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
      until kubectl get crd oidcclients.management.cattle.io > /dev/null 2>&1 ; do echo "OIDCClient crd is not ready yet, sleeping 10s" && sleep 10s; done
      kubectl apply -f - <<EOF
      apiVersion: management.cattle.io/v3
      kind: OIDCClient
      metadata:
        name: oidc-observability-downstream
      spec:
        tokenExpirationSeconds: 600
        refreshTokenExpirationSeconds: 3600
        redirectURIs:
          - "https://observability.${local.domain_downstream_url}/loginCallback?client_name=StsOidcClient"
      EOF
    EOT
  }
}

data "external" "suse_observability_downstream_oidc_rancher" {
  count      = var.longhorn_downstream_install && var.stackstate_downstream_install && var.stackstate_downstream_license != "" && var.stackstate_downstream_rancher_oidc && var.create_downstream_cluster ? 1 : 0
  depends_on = [null_resource.create_suse_observability_downstream_rancher_oidc]
  program = ["bash", "-c", <<EOT
    export KUBECONFIG=${local.kc_path}/${var.prefix}_kubeconfig.yaml
    sleep 5s
    CLIENT_ID=$(kubectl get oidcclients.management.cattle.io oidc-observability-downstream -o jsonpath='{.status.clientID}')
    CLIENT_SECRET=$(kubectl get secret $CLIENT_ID -n cattle-oidc-client-secrets -o jsonpath='{.data.client-secret-1}' | base64 -d)
    echo "{\"client_id\": \"$CLIENT_ID\", \"client_secret\": \"$CLIENT_SECRET\"}"
  EOT
  ]
}

resource "local_file" "observability_downstream_rancher_oidc_values" {
  count      = var.longhorn_downstream_install && var.stackstate_downstream_install && var.stackstate_downstream_license != "" && var.stackstate_downstream_rancher_oidc && var.create_downstream_cluster ? 1 : 0
  depends_on = [data.external.suse_observability_downstream_oidc_rancher]
  content = templatefile("${path.cwd}/suse-observability-values/templates/rancher-oidc.tpl", {
    baseUrl       = "https://rancher.${local.domain_url}"
    client_id     = data.external.suse_observability_downstream_oidc_rancher[0].result.client_id
    client_secret = data.external.suse_observability_downstream_oidc_rancher[0].result.client_secret
  })
  filename = "${path.cwd}/suse-observability-values/templates/rancher-oidc.yaml"
}

resource "null_resource" "suse_observability_downstream_template" {
  count      = var.longhorn_downstream_install && var.stackstate_downstream_install && var.stackstate_downstream_license != "" && var.create_downstream_cluster ? 1 : 0
  depends_on = [null_resource.create_downstream_cluster_issuer, local_file.observability_downstream_rancher_oidc_values]
  provisioner "local-exec" {
    command = <<EOT
    helm repo add suse-observability https://charts.rancher.com/server-charts/prime/suse-observability
    helm repo update
    helm template --set license='${var.stackstate_downstream_license}' --set baseUrl='https://observability.${local.domain_downstream_url}' --set rancherUrl='https://rancher.${local.domain_url}' --set sizing.profile='${var.stackstate_downstream_sizing}' suse-observability-values suse-observability/suse-observability-values --output-dir .
    helm --kubeconfig ${local.kc_path}/${local.downstream_prefix}_kubeconfig.yaml upgrade --install suse-observability suse-observability/suse-observability --namespace suse-observability --values ${path.cwd}/suse-observability-values/templates/baseConfig_values.yaml --values ${path.cwd}/suse-observability-values/templates/sizing_values.yaml --values ${path.cwd}/suse-observability-values/templates/ingress_values.yaml ${var.stackstate_downstream_rancher_oidc ? "--values ${path.cwd}/suse-observability-values/templates/rancher-oidc.yaml" : ""} --create-namespace
    EOT
  }
}

data "external" "suse_observability_downstream_password" {
  count      = var.longhorn_downstream_install && var.stackstate_downstream_install && var.stackstate_downstream_license != "" && !var.stackstate_downstream_rancher_oidc ? 1 : 0
  depends_on = [null_resource.suse_observability_template]
  program = ["bash", "-c", <<EOT
    PASSWORD=$(cat suse-observability-values/templates/baseConfig_values.yaml | grep "Observability admin password" | awk '{print $8}')
    echo "{\"password\": \"$PASSWORD\"}"
  EOT
  ]
}