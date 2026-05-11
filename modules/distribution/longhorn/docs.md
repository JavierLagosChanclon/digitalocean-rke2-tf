## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.longhorn](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.longhorn_dependencies](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_longhorn_enabled"></a> [longhorn\_enabled](#input\_longhorn\_enabled) | Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is true. | `bool` | `false` | no |
| <a name="input_longhorn_host"></a> [longhorn\_host](#input\_longhorn\_host) | Specifies the hostname used to expose Longhorn via Ingress (e.g. sslip.io or custom domain). Default is null. | `string` | `null` | no |
| <a name="input_longhorn_version"></a> [longhorn\_version](#input\_longhorn\_version) | Specifies the Longhorn Helm chart version to install. Default is null (latest version). | `string` | `null` | no |
| <a name="input_node_ips"></a> [node\_ips](#input\_node\_ips) | Specifies the list of node public IP addresses used to prepare Longhorn dependencies on each cluster node. | `list(string)` | `[]` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Specifies the SSH private key content used to connect to cluster nodes for Longhorn dependency preparation. | `string` | n/a | yes |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | Specifies the SSH username used to connect to cluster nodes. Default is 'opensuse'. | `string` | `"opensuse"` | no |

## Outputs

No outputs.
