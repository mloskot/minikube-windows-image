# minikube-windows-image

> [!CAUTION]
> This is an experiment related to https://github.com/kubernetes/minikube/issues/22483

## Usage

Help: `make help`

```bash
az login
```

```bash
export MINIKUBE_AZ_RESOURCE_GROUP="rg-mloskot"
export MINIKUBE_AZ_SUBSCRIPTION_ID="$(az account show --query 'id' --output tsv)"
export MINIKUBE_AZ_TENANT_ID="$(az account show --query 'tenantId' --output tsv)"
```

or, if using [mise](https://mise.jdx.dev), run `make env` to generate `.mise.local.toml`.

```bash
make preflight
```

```bash
make azure-deploy
```
