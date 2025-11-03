output "rancher_url" {
  description = "WebUI to access Rancher"
  value       = "https://rancher.${local.domain_url}"
}

output "Rancher_password" {
  description = "Password to access rancher with admin user"
  value       = var.rancher_password
}

output "neuvector_url" {
  description = "WebUI to access NeuVector"
  value       = var.neuvector_install && var.neuvector_external_ingress ? "https://neuvector.${local.domain_url}" : "Neuvector has been deployed and can be accessed through Rancher UI"
}


output "SuseObservability_url" {
  value       = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" ? "https://observability.${local.domain_url}" : null
  description = "SuseObservability_url"
}

output "SuseObservability_password" {
  value       = var.longhorn_install && var.stackstate_install && var.stackstate_license != "" && !var.stackstate_rancher_oidc ? data.external.suse_observability_password[0].result["password"] : null
  description = "SuseObservability_password"
}

output "downstream_loadbalancer_ip" {
  value       = var.create_downstream_cluster ? digitalocean_loadbalancer.downstream_rke2_lb[0].ip : null
  description = "downstream_loadbalancer_ip"
}

output "neuvector_downstream_url" {
  description = "WebUI to access NeuVector on downstream cluster"
  value       = var.neuvector_downstream_install && var.neuvector_downstream_external_ingress ? "https://neuvector.${local.domain_downstream_url}" : "Neuvector has been deployed and can be accessed through Rancher UI"
}


output "SuseObservability_downstream_url" {
  value       = var.longhorn_downstream_install && var.stackstate_downstream_install && var.stackstate_downstream_license != "" && var.create_downstream_cluster ? "https://observability.${local.domain_downstream_url}" : null
  description = "SuseObservability_url"
}

output "SuseObservability_downstream_password" {
  value       = var.longhorn_downstream_install && var.stackstate_downstream_install && var.stackstate_downstream_license != "" && !var.stackstate_downstream_rancher_oidc ? data.external.suse_observability_downstream_password[0].result["password"] : null
  description = "SuseObservability_password"
}
