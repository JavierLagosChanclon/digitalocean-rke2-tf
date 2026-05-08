locals {
  private_ssh_key_path = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  public_ssh_key_path  = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
}

resource "tls_private_key" "ssh_private_key" {
  algorithm = "ED25519"
}

resource "local_file" "private_key_pem" {
  filename        = local.private_ssh_key_path
  content         = tls_private_key.ssh_private_key.private_key_openssh
  file_permission = "0600"
}

resource "local_file" "public_key_pem" {
  filename        = local.public_ssh_key_path
  content         = tls_private_key.ssh_private_key.public_key_openssh
  file_permission = "0600"
}

resource "digitalocean_ssh_key" "do_pub_created_ssh" {
  name       = "${var.prefix}-pub-key"
  public_key = tls_private_key.ssh_private_key.public_key_openssh
}
