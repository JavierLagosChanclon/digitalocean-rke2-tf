output "image_id" {
  description = "The ID of the custom OS image used for all RKE2 cluster droplets."
  value       = digitalocean_custom_image.upload_certified_image.id
}
