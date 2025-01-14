output "rancher_url" {
  description = "WebUI to access Rancher"
  value       = "https://rancher.${digitalocean_loadbalancer.rke2_lb.ip}.sslip.io"
}

output "Rancher_password" {
  description = "Password to access rancher with admin user"
  value       = var.rancher_password
}

output "neuvector_url" {
  description = "WebUI to access NeuVector"
  value = var.neuvector_install ? "https://neuvector.${digitalocean_loadbalancer.rke2_lb.ip}.sslip.io" : null
}


output "SuseObservability_url" {
  value = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" ? "https://observability.${digitalocean_loadbalancer.rke2_lb.ip}.sslip.io" : null
  description = "SuseObservability_url"
}
