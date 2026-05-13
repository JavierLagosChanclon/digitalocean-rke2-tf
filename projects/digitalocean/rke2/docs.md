## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | 2.85.1 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.1.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | 14.1.0 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ../../../modules/distribution/cert-manager | n/a |
| <a name="module_identity"></a> [identity](#module\_identity) | ../../../modules/identity/ssh | n/a |
| <a name="module_longhorn"></a> [longhorn](#module\_longhorn) | ../../../modules/distribution/longhorn | n/a |
| <a name="module_os_image"></a> [os\_image](#module\_os\_image) | ../../../modules/custom-os-image | n/a |
| <a name="module_rancher"></a> [rancher](#module\_rancher) | ../../../modules/distribution/rancher | n/a |
| <a name="module_rke2_additional_servers"></a> [rke2\_additional\_servers](#module\_rke2\_additional\_servers) | ../../../modules/distribution/rke2 | n/a |
| <a name="module_rke2_additional_workers"></a> [rke2\_additional\_workers](#module\_rke2\_additional\_workers) | ../../../modules/distribution/rke2 | n/a |
| <a name="module_rke2_first"></a> [rke2\_first](#module\_rke2\_first) | ../../../modules/distribution/rke2 | n/a |
| <a name="module_rke2_first_server"></a> [rke2\_first\_server](#module\_rke2\_first\_server) | ../../../modules/infrastructure/digitalocean/droplet | n/a |
| <a name="module_rke2_servers"></a> [rke2\_servers](#module\_rke2\_servers) | ../../../modules/infrastructure/digitalocean/droplet | n/a |
| <a name="module_rke2_workers"></a> [rke2\_workers](#module\_rke2\_workers) | ../../../modules/infrastructure/digitalocean/droplet | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.kubeconfig_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.rke2_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [ssh_resource.retrieve_kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/2.7.0/docs/resources/resource) | resource |
| [local_file.ssh_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certmanager_version"></a> [certmanager\_version](#input\_certmanager\_version) | Cert-manager Helm chart version. If empty, latest version will be installed. Default is null (latest version). | `string` | `null` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Specifies the size of the additional data disks attached to the Droplet, in GB. Default is '350'. | `number` | `350` | no |
| <a name="input_do_ssh_key_id"></a> [do\_ssh\_key\_id](#input\_do\_ssh\_key\_id) | Existing SSH key ID to use. If null, module will use or create one. | `string` | `null` | no |
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | DigitalOcean API token used to deploy the infrastructure. Default is 'null'. | `string` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Specifies the ID of the custom OS image used to provision all RKE2 cluster droplets. Defailt is empty. | `string` | `""` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Specifies the number of Droplets (nodes) to create for the RKE2 cluster. This value defines the total cluster size, including the first server node, additional server nodes (if count <= 3), and worker nodes (if count > 3). Default is 1. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the name of the DigitalOcean Droplet type. Default is 'g-16vcpu-64gb'. | `string` | `"g-16vcpu-64gb"` | no |
| <a name="input_longhorn_enabled"></a> [longhorn\_enabled](#input\_longhorn\_enabled) | Specifies whether Longhorn should be installed on the Kubernetes cluster. Default is false. | `bool` | `false` | no |
| <a name="input_longhorn_version"></a> [longhorn\_version](#input\_longhorn\_version) | Specifies the Longhorn Helm chart version to install. Default is null (latest version). | `string` | `null` | no |
| <a name="input_node_role"></a> [node\_role](#input\_node\_role) | Specifies the RKE2 node role for this instance. Valid values are 'server' or 'agent'. The role determines whether the node participates in the control plane/etcd cluster ('server') or joins as a worker node ('agent'). Default is 'agent'. | `string` | `"agent"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Specifies the prefix added to the names of all resources. Default is 'do-tf'. | `string` | `"do-tf"` | no |
| <a name="input_rancher_bootstrap_password"></a> [rancher\_bootstrap\_password](#input\_rancher\_bootstrap\_password) | Specifies the bootstrap administrator password used during Rancher installation. Must be at least 12 characters when Rancher is enabled. | `string` | `null` | no |
| <a name="input_rancher_enabled"></a> [rancher\_enabled](#input\_rancher\_enabled) | Specifies whether Rancher should be installed on the Kubernetes cluster. Default is false. | `bool` | `false` | no |
| <a name="input_rancher_tls_source"></a> [rancher\_tls\_source](#input\_rancher\_tls\_source) | Specifies the TLS certificate source used by Rancher. Default is 'letsEncrypt'. | `string` | `"letsEncrypt"` | no |
| <a name="input_rancher_version"></a> [rancher\_version](#input\_rancher\_version) | Specifies the Rancher Helm chart version to install. Default is null (latest version). | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Specifies the DigitalOcean region used for all resources. Default is 'fra1'. | `string` | `"fra1"` | no |
| <a name="input_rke2_config"></a> [rke2\_config](#input\_rke2\_config) | Specifies additional custom RKE2 configuration in YAML format. Default is empty. | `string` | `""` | no |
| <a name="input_rke2_ingress"></a> [rke2\_ingress](#input\_rke2\_ingress) | Specifies the ingress controller to deploy. Allowed values are 'traefik', 'nginx', or 'none'. Default is 'traefik'. | `string` | `"traefik"` | no |
| <a name="input_rke2_token"></a> [rke2\_token](#input\_rke2\_token) | Specifies the shared token used by all nodes to join the RKE2 cluster. Default is 'null'. | `string` | `null` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | Specifies the RKE2 version to install. Default is 'v1.35.4+rke2r1'. | `string` | `"v1.35.4+rke2r1"` | no |
| <a name="input_server_url"></a> [server\_url](#input\_server\_url) | Specifies the URL of the first RKE2 server node (required for 'server' and 'agent' roles). Default is 'null'. | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Specifies cloud-init user\_data used to bootstrap the Droplet. Default is 'null'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_first_server_public_ip"></a> [first\_server\_public\_ip](#output\_first\_server\_public\_ip) | n/a |
| <a name="output_longhorn_url"></a> [longhorn\_url](#output\_longhorn\_url) | n/a |
| <a name="output_rancher_url"></a> [rancher\_url](#output\_rancher\_url) | n/a |
| <a name="output_server_nodes_public_ip"></a> [server\_nodes\_public\_ip](#output\_server\_nodes\_public\_ip) | n/a |
| <a name="output_worker_nodes_public_ip"></a> [worker\_nodes\_public\_ip](#output\_worker\_nodes\_public\_ip) | n/a |
