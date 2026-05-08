output "ssh_private_key" {
  description = "Private SSH key generated for the infrastructure."
  value       = tls_private_key.ssh_private_key.private_key_openssh
  sensitive   = true
}

output "ssh_public_key" {
  description = "Public SSH key generated for the infrastructure."
  value       = tls_private_key.ssh_private_key.public_key_openssh
}

output "ssh_key_id" {
  description = "DigitalOcean SSH key ID generated for the infrastructure."
  value       = digitalocean_ssh_key.do_pub_created_ssh.id
}

output "private_ssh_key_path" {
  description = "Path of the generated SSH private key."
  value       = local.private_ssh_key_path
}

output "public_ssh_key_path" {
  description = "Path of the generated SSH public key."
  value       = local.public_ssh_key_path
}
