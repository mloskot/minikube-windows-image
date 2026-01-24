# minikube-windows-image

> [!WARNING]
> This is an experiment related to https://github.com/kubernetes/minikube/issues/22483

> [!CAUTION]
> Minikube was granted access to Azure resource group `SIG-CLUSTER-LIFECYCLE-MINIKUBE` managed by SIG-Cluster-Lifecycle/SIG-Windows.
> We must **NOT** attempt to delete this resource group!
>
> Unfortunately, locking the resource group would not help, becuase it also locks any contained resources:
>
>    ```bash
>    az group lock create --lock-type CanNotDelete \
>       --name "CanNotDelete-${MINIKUBE_AZ_RESOURCE_GROUP}" \
>       --resource-group "${MINIKUBE_AZ_RESOURCE_GROUP}" \
>       --notes "Group managed by SIG-Windows"
>    ```
>

## Features

The goal of the project is to build Windows-based golden image for Minikube in order
to create create short-lived ephemeral Azure Virtual Machines used for testing.

The project provides:

1. Bicep templates to create Shared Image Gallery on Azure in given resource group.
2. Packer templates to build single Virtual Machine image:
    - based on Windows 11 with Windows settings optimized and bloatware removed
    - [specialized, not generalized](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries#generalized-and-specialized-images), and [shallowly replicated](https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries#shallow-replication)
    - provisioned with *non-secret* local administrator with [username and password fixed](packer/variables.pkr.hcl):
      - username: `minikubeadmin`
      - password: `M!n!kub34dm!n`
    - provisioned with *non-secret* [SSH key](ssh/) for streamlined authentication
    - provisioned with [tools required to run Minikube tests](packer/provisioners/))

3. Packer configuration to publish it to the Azure Shared Image Gallery.
4. Bicep templates to create Azure Virtual Machine from the published image to verify the output of the image build.

## Usage

Help: `make help`

### Configure

1. Set up Azure CLI:

    ```bash
    az login
    ```

    or keep the Azure CLI profile in project-specific location (recommended? safety?):

    ```bash
    export AZURE_CONFIG_DIR=$HOME/.azure-minikube-windows-image
    az login
    ```

2. Set up environment variables

    ```bash
    source ./env.sh
    ```

    Alternatively, install [mise](https://mise.jdx.dev) and let it load [.mise.toml](.mise.toml).

### Build

Run `make help` to learn about available commands.

```bash
source ./env.sh
make preflight                  # verify your environment
make sig-deploy                 # create Shared Image Gallery on Azure
make packer-build-and-publish   # build VM image and push it to the gallery
```

### Test

Find IP and FQDN of VM:

```bash
make vm-deploy  # create VM from the image
make vm-fqdn    # prints public IP and FQDN
```

Connect using password:

```bash
export SSHPASS='M!n!kub34dm!n'
sshpass -e ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no minikubeadmin@vm-minikube-ci.${AZURE_DEFAULTS_LOCATION}.cloudapp.azure.com
```

Connect using SSH key:

```bash
ssh -i ./ssh/id_ecdsa.txt  -o StrictHostKeyChecking=no minikubeadmin@vm-minikube-ci.${AZURE_DEFAULTS_LOCATION}.cloudapp.azure.com
```
