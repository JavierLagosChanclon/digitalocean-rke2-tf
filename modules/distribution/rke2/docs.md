## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_string.rke2_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Specifies the number of nodes expected in the RKE2 cluster topology. Must be either 1 for a single-node cluster or >= 3 for a highly available cluster. Default is '1'. | `number` | `1` | no |
| <a name="input_rke2_config"></a> [rke2\_config](#input\_rke2\_config) | Specifies additional custom RKE2 configuration in YAML format. Default is empty. | `string` | `""` | no |
| <a name="input_rke2_ingress"></a> [rke2\_ingress](#input\_rke2\_ingress) | Specifies the ingress controller to deploy. Allowed values are 'traefik', 'nginx', or 'none'. Default is 'traefik'. | `string` | `"traefik"` | no |
| <a name="input_rke2_token"></a> [rke2\_token](#input\_rke2\_token) | Specifies the shared token used by all nodes to join the RKE2 cluster. Default is 'null'. | `string` | `null` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | Specifies the RKE2 version to install. Default is 'v1.35.4+rke2r1'. | `string` | `"v1.35.4+rke2r1"` | no |
| <a name="input_server_url"></a> [server\_url](#input\_server\_url) | Specifies the URL of the first RKE2 server node (required for 'server' and 'agent' roles). Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_install_type"></a> [install\_type](#output\_install\_type) | Indicates whether the node is installed as 'server' or 'agent'. |
| <a name="output_user_data"></a> [user\_data](#output\_user\_data) | Cloud-init user\_data script used to bootstrap the RKE2 node. |
