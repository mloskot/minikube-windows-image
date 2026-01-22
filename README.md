# minikube-windows-image

> [!CAUTION]
> This is an experiment related to https://github.com/kubernetes/minikube/issues/22483

## Features

The project provides:

1. Bicep templates to create Shared Image Gallery on Azure in given resource group.
2. Packer templates to build single Virtual Machine image:
    - based on Windows 11
    - specialized (not generalized!)
    - configured with single pre-defined account for local administrator `minikubeadmin`
    - with Windows settings optimized and bloatware removed
    - provisioned with tools required to run Minikube tests

   and publish it to the Shared Image Gallery.
3. Bicep templates to create a test Virtual Machine from the published image to verify the output of the image build.

## Usage

Help: `make help`

### Configure environment

1. Set up Azure CLI configuration:

    ```bash
    az login
    ```

2. Create required input parameters:

    ```bash
    export MINIKUBE_AZ_RESOURCE_GROUP="SIG-CLUSTER-LIFECYCLE-MINIKUBE"
    export MINIKUBE_AZ_SUBSCRIPTION_ID="$(az account show --query 'id' --output tsv)"
    export MINIKUBE_AZ_TENANT_ID="$(az account show --query 'tenantId' --output tsv)"
    export MINIKUBE_AZ_LOCATION="southcentralus"
    ```

    Alternatively, install [mise](https://mise.jdx.dev) and let `make` generate `.mise.local.toml` file:
    
    ```bash
    cd minikube-windows-image
    mise trust
    make env
    ```

3. Create Azure resource group, if it does not exist:

    ```bash
    az group create --name "${MINIKUBE_AZ_RESOURCE_GROUP}" --location=<eastus, westus, uksouth, etc.>
    ```

### Build image

```bash
make preflight                # check Azure CLI authentication and environment variables
make azure-deploy             # create Shared Image Gallery on Azure
make packer-build-and-publish # build VM images and pushes it to the gallery
```

### Test image

```bash
TODO
```
