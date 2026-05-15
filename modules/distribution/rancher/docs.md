## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.rancher](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.rancher_tls_secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_cert_request.rancher](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.rancher](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.rancher](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to kubeconfig file used by kubectl. Default is null. | `string` | `null` | no |
| <a name="input_rancher_bootstrap_password"></a> [rancher\_bootstrap\_password](#input\_rancher\_bootstrap\_password) | Specifies the bootstrap administrator password used during Rancher installation. Must be at least 12 characters when Rancher is enabled. | `string` | `null` | no |
| <a name="input_rancher_enabled"></a> [rancher\_enabled](#input\_rancher\_enabled) | Specifies whether Rancher should be installed on the Kubernetes cluster. Default is false. | `bool` | `false` | no |
| <a name="input_rancher_hostname"></a> [rancher\_hostname](#input\_rancher\_hostname) | Specifies the hostname used to expose Rancher via Ingress. | `string` | n/a | yes |
| <a name="input_rancher_tls_source"></a> [rancher\_tls\_source](#input\_rancher\_tls\_source) | Specifies the TLS certificate source used by Rancher. Default is 'letsEncrypt'. | `string` | `"letsEncrypt"` | no |
| <a name="input_rancher_version"></a> [rancher\_version](#input\_rancher\_version) | Specifies the Rancher Helm chart version to install. Default is null (latest version). | `string` | `null` | no |

## Outputs

No outputs.
