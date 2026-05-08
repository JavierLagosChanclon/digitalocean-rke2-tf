## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | 2.85.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.85.1 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_droplet.nodes](https://registry.terraform.io/providers/digitalocean/digitalocean/2.85.1/docs/resources/droplet) | resource |
| [digitalocean_firewall.example_firewall](https://registry.terraform.io/providers/digitalocean/digitalocean/2.85.1/docs/resources/firewall) | resource |
| [digitalocean_volume.data_disk](https://registry.terraform.io/providers/digitalocean/digitalocean/2.85.1/docs/resources/volume) | resource |
| [digitalocean_volume_attachment.data_disk_attachment](https://registry.terraform.io/providers/digitalocean/digitalocean/2.85.1/docs/resources/volume_attachment) | resource |
| [random_id.volume_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_disk_count"></a> [data\_disk\_count](#input\_data\_disk\_count) | Specifies the number of additional data disks to attach to each VM instance. Default is 1. | `number` | `1` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of each additional data disks attached to the Droplet, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Specifies the ID of the custom OS image used to provision all RKE2 cluster droplets. Defailt is empty. | `string` | `""` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Specifies the number of Droplets to create. Default is 1. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of the DigitalOcean Droplet type. Default is 'g-16vcpu-64gb'. | `string` | `"g-16vcpu-64gb"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'do-tf'. | `string` | `"do-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the DigitalOcean region used for all resources. Default is 'fra1'. | `string` | `"fra1"` | no |
| <a name="input_ssh_key_id"></a> [ssh\_key\_id](#input\_ssh\_key\_id) | n/a | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Specifies cloud-init user\_data used to bootstrap the Droplet. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instances_public_ip"></a> [instances\_public\_ip](#output\_instances\_public\_ip) | Public IP addresses of the DigitalOcean Droplets. |
