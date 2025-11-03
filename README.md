# RKE2 | DigitalOcean | Rancher/Cert-manager/Longhorn/NeuVector/StackState

This repo will allow you to create a RKE2 upstream cluster and/or downstream RKE2 cluster with the desired number of nodes and will deploy automatically the following components:
```
- Rancher: Automatically deployed with HTTPS ingress resource and valid SSL cert.
- Cert-manager: Automatically deployed. Used to create ingress HTTPS certificates.
- Longhorn: Storage Provider is only installed if the variable longhorn_install is set to true. All dependencies to make Longhorn work are automatically deployed when variable is defined as expected.
- Neuvector: Only installed if variable neuvector_install is set to true with HTTPS ingress resource and valid SSL cert. In case that Longhorn has been installed NeuVector will be configured with a 30GB PVC for controller pods.
- StackSate: Only installed if the following variables have been defined as follow: stackstate_install=true, stackstate_license="<LICENSE>" and longhorn_install=true with HTTPS ingress resource and valid SSL cert.
```

## Usage

```bash
git clone https://github.com/JavierLagosChanclon/digitalocean-rke2-tf.git
```

- Copy `./terraform.tfvars.example` to `./terraform.tfvars`
- Edit `./terraform.tfvars`
  - Update the required variables:
    -  `do_token` To specify the token used to authenticate with DigitalOcean API.
    -  `region` To define region where droplets and LoadBalancer will be created. The following link can be useful to select DigitalOcean region. -> https://slugs.do-api.dev/
    -  `size` To define Droplet size. The following link can be useful to select Droplet size. -> https://slugs.do-api.dev/
    -  `droplet_count` To specify the number of instances to create. First 3 nodes will be configured as master nodes while the rest will be workers.
    -  `prefix` To specify prefix defined in objects created on DigitalOcean.
    -  `rancher_password` To configure the initial Admin rancher password (the password must be at least 12 characters).

#### IMPORTANT INFORMATION

- The required variables explained before will help to create a RKE2 upstream cluster by deploying only Rancher and Cert-manager components with valid HTTPS access. In case that you want leverage and use all the potential of the Terraform script you may want to use the rest of the variables:
  - Optional variables:
    - `rke2_version` To define rke2 version installed. By default it will install stable latest version available.
    - `kubeconfig_path` To specify where Kubeconfig file will be located to execute Kubectl commands to the cluster created. By default, it will be located at the current folder.
    - `use_digitalocean_domain` To specify whether we want to use a custom domain already created on the DO account or not. If set as false sslip.io domain will be used. Please be careful about sslip.io limitation with let's encrypt
    - `digitalocean_domain` To define the custom domain created on DigitalOcean account. Here is where some records will be created.
    - `longhorn_install` If longhorn_install variable is set to true, Longhorn will be deployed and nodes will be configured for longhorn to work. By default, longhorn_install variable is set to false.
    - `neuvector_install` If neuvector_install variable is set to true, NeuVector will be deployed and if longhorn_install is true NeuVector will be configured with persistent storage. By default, neuvector_install variable is set to false.
    - `neuvector_external_ingress` If neuvector_external_ingress is set to true, one ingress object to access NeuVector URL will be created. By default, NeuVector can be accessed through Rancher UI.
    - `stackstate_install` If stackstate_install variable is set to true, stackstate_license variable contains a license and longhorn_install variable is set to true StackState will be deployed. By default, stackstate_install variable is set to false.
    - `stackstate_license` To define valid StackState license.
    - `stackstate_sizing` To define StackState size based on the StackState documentation https://docs.stackstate.com/self-hosted-setup/install-stackstate/requirements. Please ensure that RKE2 cluster that will be deployed has enough storage and CPU/Memory available to deploy StackState before defining size.
    - `stackstate_create_oltp_ingress` If stackstate_create_oltp_ingress is set to true, OLTP ingresses will be created for SUSE observability.
    - `stackstate_rancher_oidc` If stackstate_rancher_oidc is set to true, SUSE Observability will be configured to use rancher upstream cluster as OIDC provider automatically.
    - `rancher_version/neuvector_version/longhorn_version` To define component helm version deployed. By default, it will deploy latest helm version available.
    - `create_downstream_cluster` To define if a downstream cluster managed by upstream rancher will be created.
    - `downstream_droplet_count` To specify the number of downstream nodes to create.
    - `downstream_size` To specify the droplet size for downstream nodes.
    - `downstream_cni` To define CNI type used by downstream cluster. You can choose between canal, calico and flannel.
    - `longhorn_downstream_install` If longhorn_downstream_install variable is set to true, Longhorn will be deployed and nodes will be configured for longhorn to work on the downstream cluster. By default, longhorn_install variable is set to false.
    - `neuvector_downstream_install` If neuvector_downstream_install variable is set to true on the downstream cluster, NeuVector will be deployed and if longhorn_downstream_install is true Neuvector will be configured with persistent storage. By default, neuvector_downstream_install variable is set to false.
    - `neuvector_downstream_external_ingress` If neuvector_downstream_external_ingress is set to true, one ingress object to access NeuVector URL located on the downstream cluster will be created. By default, NeuVector can be accessed through Rancher UI.
    - `stackstate_downstream_license` To define valid StackState license.
    - `stackstate_downstream_install`  If stackstate_downstream_install variable is set to true, stackstate_downstream_license variable contains a license and longhorn_downstream_install variable is set to true StackState will be deployed on the downstream cluster. By default, stackstate_downstream_install variable is set to false.
    - `stackstate_downstream_sizing` To define StackState size based on the StackState documentation https://docs.stackstate.com/self-hosted-setup/install-stackstate/requirements. Please ensure that RKE2 downstream cluster that will be deployed has enough storage and CPU/Memory available to deploy StackState before defining size.
    - `stackstate_downstream_create_oltp_ingress` If stackstate_create_oltp_ingress is set to true, OLTP ingresses will be created for SUSE observability on the downstream cluster.
    - `stackstate_downstream_rancher_oidc` If stackstate_rancher_oidc is set to true, SUSE Observability deployed on downstream cluster will be configured to use rancher upstream cluster as OIDC provider automatically.
    - `neuvector_downstream_version/longhorn_downstream_version` To define component helm version deployed on downstream cluster. By default, it will deploy latest helm version available.
    - StackState Ingress URL will not be available until 5/10 minutes after Terraform script has finished since StackState requires more time the first time it is installed.
    - StackState Admin password will be displayed on the output when terraform script finishes. If you want to see it again please run `terraform output`. When variable stackstate_rancher_oidc is set to true, there is no "admin" password as the authentication goes through Rancher.


#### terraform.tfvars example
- Here can be found an example of terraform.tfvars file.
```
do_token = "<do-access-token>"
region = "fra1"
size = "s-8vcpu-16gb"
droplet_count = 3
prefix = ""<your-name>-rke2"
# rancher_password = ""
# rke2_token = ""
# rke2_version= ""
use_digitalocean_domain = true
digitalocean_domain = "domain.created.on.digitalOcean"
# kubeconfig_path = ""
# rancher_version = ""
neuvector_install = true
longhorn_install = true
# neuvector_version = ""
# longhorn_version = ""
# neuvector_external_ingress = true/false
# stackstate_install = true/false
# stackstate_license = "<valid-license>"
# stackstate_sizing = ""
# stackstate_create_oltp_ingress = true/false
# stackstate_rancher_oidc = true/false
# create_downstream_cluster = true/false
# downstream_droplet_count = 1
# downstream_cni = ""
# downstream_size = ""
# longhorn_downstream_install = true/false
# longhorn_downstream_version = ""
# neuvector_downstream_install = true/false
# neuvector_downstream_version = ""
# neuvector_downstream_external_ingress = true/false
# stackstate_downstream_license = ""
# stackstate_downstream_install = true/false
# stackstate_downstream_sizing = ""
# stackstate_downstream_create_oltp_ingress = true/false
# stackstate_downstream_rancher_oidc = true/false'
```


#### Terraform Apply

```bash
terraform init -upgrade && terraform apply -auto-approve
```

#### Terraform Destroy

```bash
terraform destroy -auto-approve
```

