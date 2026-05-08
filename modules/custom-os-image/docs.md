## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | 2.85.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.85.1 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_custom_image.upload_certified_image](https://registry.terraform.io/providers/digitalocean/digitalocean/2.85.1/docs/resources/custom_image) | resource |
| [null_resource.download_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'do-tf'. | `string` | `"do-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the DigitalOcean region used for all resources. Default is 'fra1'. | `string` | `"fra1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | The ID of the custom OS image used for all RKE2 cluster droplets. |
