## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | 2.85.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.85.1 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_ssh_key.do_pub_created_ssh](https://registry.terraform.io/providers/digitalocean/digitalocean/2.85.1/docs/resources/ssh_key) | resource |
| [local_file.private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.public_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ssh_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is empty. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_ssh_key_path"></a> [private\_ssh\_key\_path](#output\_private\_ssh\_key\_path) | Path of the generated SSH private key. |
| <a name="output_public_ssh_key_path"></a> [public\_ssh\_key\_path](#output\_public\_ssh\_key\_path) | Path of the generated SSH public key. |
| <a name="output_ssh_key_id"></a> [ssh\_key\_id](#output\_ssh\_key\_id) | DigitalOcean SSH key ID generated for the infrastructure. |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | Private SSH key generated for the infrastructure. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | Public SSH key generated for the infrastructure. |
