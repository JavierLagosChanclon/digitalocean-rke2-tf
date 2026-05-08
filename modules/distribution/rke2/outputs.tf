output "user_data" {
  description = "Cloud-init user_data script used to bootstrap the RKE2 node."
  value       = local.user_data
}

output "install_type" {
  description = "Indicates whether the node is installed as 'server' or 'agent'."
  value       = local.install_type
}
