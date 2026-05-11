## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_node_role"></a> [node\_role](#input\_node\_role) | Specifies the RKE2 node role for this instance. Valid values are 'server' or 'agent'. The role determines whether the node participates in the control plane/etcd cluster ('server') or joins as a worker node ('agent'). Default is 'agent'. | `string` | `"agent"` | no |
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
