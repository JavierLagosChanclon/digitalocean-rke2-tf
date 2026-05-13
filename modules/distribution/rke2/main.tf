locals {
  install_type = var.node_role

  base_config = <<-EOF
token: ${var.rke2_token}
write-kubeconfig-mode: "0644"
ingress-controller: ${var.rke2_ingress}
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
  # Wait volume attachment
  - |
      for i in $(seq 1 60); do
        if [ -b /dev/sda ]; then
          echo "Disk /dev/sda found"
          break
        fi
        echo "Waiting for /dev/sda..."
        sleep 2
      done
  # Ensure udev has settled
  - udevadm settle
  # Partition disk
  - |
      if ! blkid /dev/sda1; then
        echo "Partitioning disk..."
        parted /dev/sda --script mklabel gpt
        parted /dev/sda --script mkpart primary xfs 0% 100%
        mkfs.xfs -f /dev/sda1
      fi
  # Mount rancher storage
  - mkdir -p /var/lib/rancher
  - |
      UUID=$(blkid -s UUID -o value /dev/sda1)
      grep -q "$UUID" /etc/fstab || \
      echo "UUID=$UUID /var/lib/rancher xfs defaults,noatime,nodiratime,nofail,x-systemd.device-timeout=30 0 2" >> /etc/fstab
  - systemctl daemon-reload
  - mount /var/lib/rancher
  # Verify mount
  - df -h /var/lib/rancher
  # Install RKE2
  - curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${var.rke2_version} INSTALL_RKE2_TYPE=${local.install_type} sh -
  - systemctl enable rke2-${local.install_type}
  - systemctl start rke2-${local.install_type}
  # Wait for kubeconfig to exist
  - |
      for i in $(seq 1 60); do
        if [ -f /etc/rancher/rke2/rke2.yaml ]; then
          break
        fi
        sleep 2
      done
  # Wait for Kubernetes API to respond
  - |
      for i in $(seq 1 90); do
        /var/lib/rancher/rke2/bin/kubectl \
          --kubeconfig /etc/rancher/rke2/rke2.yaml \
          get nodes >/dev/null 2>&1 && break
        sleep 2
      done
EOF
}
