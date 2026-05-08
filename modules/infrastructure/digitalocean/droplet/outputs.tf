output "instances_public_ip" {
  description = "Public IP addresses of the DigitalOcean Droplets."
  value       = digitalocean_droplet.nodes[*].ipv4_address
}
