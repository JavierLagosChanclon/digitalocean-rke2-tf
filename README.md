# RKE2 | DigitalOcean | Rancher/Cert-manager/Longhorn/NeuVector/StackState

This repo will allow you to create a rke2 cluster with the desired number of nodes and will deploy automatically the following components:
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
    -  `rke2_token` To specify RKE2 token required to configure nodes.
    -  `rancher_password` To configure the initial Admin rancher password (the password must be at least 12 characters).

#### IMPORTANT INFORMATION

- The required variables explained before will help to create a RKE2 cluster by deploying only Rancher and Cert-manager components with valid HTTPS access. In case that you want leverage and use all the potential of the Terraform script you may want to use the rest of the variables:
  - Optional variables:
    - `rke2_version` To define rke2 version installed. By default it will install stable latest version available.
    - `kubeconfig_path` To specify where Kubeconfig file will be located to execute Kubectl commands to the cluster created. By default, it will be located at the current folder.
    - `longhorn_install` If longhorn_install variable is set to true Longhorn will be deployed and nodes will be configured for longhorn to work. By default, longhorn_install variable is set to false.
    - `neuvector_install` If neuvector_install variable is set to true NeuVector will be deployed and if longhorn_install is true Neuvector will be configured with persistent storage. By default, neuvector_install variable is set to false.
    - `stackstate_install` If stackstate_install variable is set to true, stackstate_license variable contains a license and longhorn_install variable is set to true StackState will be deployed. By default, stackstate_install variable is set to false.
    - `stackstate_license` To define valid StackState license.
    - `stackstate_sizing` To define StackState size based on the StackState documentation https://docs.stackstate.com/self-hosted-setup/install-stackstate/requirements. Please ensure that RKE2 cluster that will be deployed has enough storage and CPU/Memory available to deploy StackState before defining size.
    - `rancher/neuvector/longhorn_version` To define component helm version deployed. By default, it will deploy latest helm version available.
  - StackState Ingress URL will not be available until 5/10 minutes after Terraform script has finished since StackState requires more time the first time it is installed.
  - StackState Admin password can be found in the suse_observability_password.txt file inside suse-observability-values/templates directory after Terraform script has finished.

#### terraform.tfvars example
- Here can be found an example of terraform.tfvars file.
```
do_token = "<do-access-token>"
region = "fra1"
size = "s-8vcpu-16gb"
droplet_count = 3
prefix = "<your-name>-rke2"
#rke2_version = ""
rke2_token = "my-token-created"
rancher_password = "<rancher-password>"
# kubeconfig_path = ""
# rancher_version = ""
neuvector_install = true
longhorn_install = true
# neuvector_version = ""
# longhorn_version = ""
stackstate_install = true
stackstate_license = "<stackstate-license>"
stackstate_sizing = "trial"
```


#### Terraform Apply

```bash
terraform init -upgrade && terraform apply -auto-approve
```

#### Terraform Destroy

```bash
terraform destroy -auto-approve
```

