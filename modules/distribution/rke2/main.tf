locals {
  install_type = var.node_role

  base_config = <<-EOF
token: ${var.rke2_token}
write-kubeconfig-mode: "0644"
ingress-controller: ${var.rke2_ingress}
snapshotter: native
EOF

  join_config = var.server_url != null ? "server: ${var.server_url}" : ""

  final_config = trimspace(
    join("\n", compact([
      local.base_config,
      local.join_config,
      var.rke2_config
    ]))
  )
}

locals {
  user_data = <<-EOF
#cloud-config

write_files:
  - path: /etc/rancher/rke2/config.yaml
    permissions: "0600"
    content: |
      ${replace(local.final_config, "\n", "\n      ")}

runcmd:
  - curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${var.rke2_version} INSTALL_RKE2_TYPE=${local.install_type} sh -
  - systemctl enable rke2-${local.install_type}
  - systemctl start rke2-${local.install_type}
EOF
}
