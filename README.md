# minikube-windows-image

> [!CAUTION]
> This is an experiment related to https://github.com/kubernetes/minikube/issues/22483

## Usage

```bash
az login
```

```bash
export MINIKUBE_AZ_RESOURCE_GROUP="rg-mloskot"
export MINIKUBE_AZ_TENANT_ID="$(az account show --query 'tenantId' --output tsv)"
export MINIKUBE_AZ_SUBSCRIPTION_ID="$(az account show --query 'id' --output tsv)"
```

or, if using mise, run `make env`.

```bash
# make ...
# outputs SSH/RDP credentials to connect to VM
```
