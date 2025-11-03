## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.30.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |
| <a name="provider_helm.downstream"></a> [helm.downstream](#provider\_helm.downstream) | 3.1.0 |
| <a name="provider_helm.main"></a> [helm.main](#provider\_helm.main) | 3.1.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.3 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_droplet.downstream_nodes](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_droplet.nodes](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_loadbalancer.downstream_rke2_lb](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/loadbalancer) | resource |
| [digitalocean_loadbalancer.rke2_lb](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/loadbalancer) | resource |
| [digitalocean_record.www](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_record.www_downstream](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_ssh_key.do_pub_created_ssh](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key) | resource |
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert-manager_downstream](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.longhorn](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.longhorn_downstream](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.neuvector-core](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.neuvector-core_downstream](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.rancher](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [local_file.observability_downstream_ingress_values](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.observability_downstream_rancher_oidc_values](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.observability_ingress_values](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.observability_rancher_oidc_values](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.public_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.create_cluster_issuer](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.create_downstream_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.create_downstream_cluster_issuer](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.create_downstream_registration_token](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.create_suse_observability_downstream_rancher_oidc](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.create_suse_observability_rancher_oidc](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.downstream_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.longhorn_dependency](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.modify_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.rke2_nginx_downstream_ingress_config](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.rke2_nginx_ingress_config](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.suse_observability_downstream_template](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.suse_observability_template](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait_for_kubernetes](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait_for_kubernetes_downstream](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [external_external.obtain_registration_command](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.suse_observability_downstream_oidc_rancher](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.suse_observability_downstream_password](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.suse_observability_oidc_rancher](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.suse_observability_password](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.upstream_rke2_version](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_downstream_cluster"></a> [create\_downstream\_cluster](#input\_create\_downstream\_cluster) | Variable to define if downstream cluster should be created | `bool` | `false` | no |
| <a name="input_digitalocean_domain"></a> [digitalocean\_domain](#input\_digitalocean\_domain) | Custom domain you already have on your account | `string` | `null` | no |
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | DigitalOcean API token | `string` | n/a | yes |
| <a name="input_downstream_cni"></a> [downstream\_cni](#input\_downstream\_cni) | Select CNI that will be installed on downstream cluster | `string` | `"canal"` | no |
| <a name="input_downstream_droplet_count"></a> [downstream\_droplet\_count](#input\_downstream\_droplet\_count) | Number of nodes created in downstream cluster | `number` | `1` | no |
| <a name="input_downstream_size"></a> [downstream\_size](#input\_downstream\_size) | Droplet size used by downstream nodes | `string` | `null` | no |
| <a name="input_droplet_count"></a> [droplet\_count](#input\_droplet\_count) | Number of droplets to create | `number` | `3` | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Kubeconfig path | `string` | `null` | no |
| <a name="input_longhorn_downstream_install"></a> [longhorn\_downstream\_install](#input\_longhorn\_downstream\_install) | Define if longhorn is installed or not on the downstream cluster | `bool` | `false` | no |
| <a name="input_longhorn_downstream_version"></a> [longhorn\_downstream\_version](#input\_longhorn\_downstream\_version) | Longhorn helm chart version for downstream installation | `string` | `""` | no |
| <a name="input_longhorn_install"></a> [longhorn\_install](#input\_longhorn\_install) | Define if longhorn is installed or not | `bool` | `false` | no |
| <a name="input_longhorn_version"></a> [longhorn\_version](#input\_longhorn\_version) | Longhorn helm chart version | `string` | `""` | no |
| <a name="input_neuvector_downstream_external_ingress"></a> [neuvector\_downstream\_external\_ingress](#input\_neuvector\_downstream\_external\_ingress) | Define if external ingress is required or not (by default it will be accessible through Rancher UI) | `bool` | `false` | no |
| <a name="input_neuvector_downstream_install"></a> [neuvector\_downstream\_install](#input\_neuvector\_downstream\_install) | Define if NeuVector is installed or not on the downstream cluster | `bool` | `false` | no |
| <a name="input_neuvector_downstream_version"></a> [neuvector\_downstream\_version](#input\_neuvector\_downstream\_version) | Neuvector helm chart version for downstream installation | `string` | `""` | no |
| <a name="input_neuvector_external_ingress"></a> [neuvector\_external\_ingress](#input\_neuvector\_external\_ingress) | Define if external ingress is required or not (by default it will be accessible through Rancher UI) | `bool` | `false` | no |
| <a name="input_neuvector_install"></a> [neuvector\_install](#input\_neuvector\_install) | Define if NeuVector is installed or not | `bool` | `false` | no |
| <a name="input_neuvector_version"></a> [neuvector\_version](#input\_neuvector\_version) | Neuvector helm chart version | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix name | `string` | `null` | no |
| <a name="input_rancher_password"></a> [rancher\_password](#input\_rancher\_password) | Rancher password used to login with admin user in webUI | `string` | `"myrancherpassword123*"` | no |
| <a name="input_rancher_version"></a> [rancher\_version](#input\_rancher\_version) | Rancher helm chart version | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the droplets will be created | `string` | `null` | no |
| <a name="input_rke2_token"></a> [rke2\_token](#input\_rke2\_token) | Token used by RKE2 server configuration | `string` | `"my-shared-token"` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | RKE2 installed version | `string` | `""` | no |
| <a name="input_size"></a> [size](#input\_size) | Droplet size | `string` | `null` | no |
| <a name="input_stackstate_create_oltp_ingress"></a> [stackstate\_create\_oltp\_ingress](#input\_stackstate\_create\_oltp\_ingress) | Defined whether OLTP stackstate ingress are required to be deployed or not | `bool` | `false` | no |
| <a name="input_stackstate_downstream_create_oltp_ingress"></a> [stackstate\_downstream\_create\_oltp\_ingress](#input\_stackstate\_downstream\_create\_oltp\_ingress) | Defined whether OLTP stackstate ingress are required to be deployed or not on the downstream cluster | `bool` | `false` | no |
| <a name="input_stackstate_downstream_install"></a> [stackstate\_downstream\_install](#input\_stackstate\_downstream\_install) | Define if StackState is installed or not | `bool` | `false` | no |
| <a name="input_stackstate_downstream_license"></a> [stackstate\_downstream\_license](#input\_stackstate\_downstream\_license) | Stackstate license used to deploy Suse Observability on downstream cluster | `string` | `""` | no |
| <a name="input_stackstate_downstream_rancher_oidc"></a> [stackstate\_downstream\_rancher\_oidc](#input\_stackstate\_downstream\_rancher\_oidc) | Defined if rancher will be used as OIDC provider on SUSE Observability deployed on downstream cluster | `bool` | `false` | no |
| <a name="input_stackstate_downstream_sizing"></a> [stackstate\_downstream\_sizing](#input\_stackstate\_downstream\_sizing) | Stackstate size used to deploy Suse Observability on downstream cluster | `string` | `"trial"` | no |
| <a name="input_stackstate_install"></a> [stackstate\_install](#input\_stackstate\_install) | Define if StackState is installed or not | `bool` | `false` | no |
| <a name="input_stackstate_license"></a> [stackstate\_license](#input\_stackstate\_license) | Stackstate license used to deploy Suse Observability | `string` | `""` | no |
| <a name="input_stackstate_rancher_oidc"></a> [stackstate\_rancher\_oidc](#input\_stackstate\_rancher\_oidc) | Defined if rancher will be used as OIDC provider on SUSE Observability | `bool` | `false` | no |
| <a name="input_stackstate_sizing"></a> [stackstate\_sizing](#input\_stackstate\_sizing) | Stackstate size used to deploy Suse Observability | `string` | `"trial"` | no |
| <a name="input_use_digitalocean_domain"></a> [use\_digitalocean\_domain](#input\_use\_digitalocean\_domain) | Variable to define whether to use DigitalOcean custom domain or not. If set as false 'sslip.io' domain will be used | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Rancher_password"></a> [Rancher\_password](#output\_Rancher\_password) | Password to access rancher with admin user |
| <a name="output_SuseObservability_downstream_password"></a> [SuseObservability\_downstream\_password](#output\_SuseObservability\_downstream\_password) | SuseObservability\_password |
| <a name="output_SuseObservability_downstream_url"></a> [SuseObservability\_downstream\_url](#output\_SuseObservability\_downstream\_url) | SuseObservability\_url |
| <a name="output_SuseObservability_password"></a> [SuseObservability\_password](#output\_SuseObservability\_password) | SuseObservability\_password |
| <a name="output_SuseObservability_url"></a> [SuseObservability\_url](#output\_SuseObservability\_url) | SuseObservability\_url |
| <a name="output_downstream_loadbalancer_ip"></a> [downstream\_loadbalancer\_ip](#output\_downstream\_loadbalancer\_ip) | downstream\_loadbalancer\_ip |
| <a name="output_neuvector_downstream_url"></a> [neuvector\_downstream\_url](#output\_neuvector\_downstream\_url) | WebUI to access NeuVector on downstream cluster |
| <a name="output_neuvector_url"></a> [neuvector\_url](#output\_neuvector\_url) | WebUI to access NeuVector |
| <a name="output_rancher_url"></a> [rancher\_url](#output\_rancher\_url) | WebUI to access Rancher |
