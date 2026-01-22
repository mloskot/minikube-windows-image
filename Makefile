# minikube-windows-image Makefile
MINIKUBE_AZ_DEPLOYMENT_NAME ?= "minikube-sig" # Azure implementation detail

.DEFAULT_GOAL := help

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

##@ General
.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY:
env: ## Generate .mise.local.toml with Azure environment specification
	echo "[env]" > .mise.local.toml
	echo MINIKUBE_AZ_DEPLOYMENT_NAME=\"$(MINIKUBE_AZ_DEPLOYMENT_NAME)\" >> .mise.local.toml
	echo MINIKUBE_AZ_RESOURCE_GROUP=\"minikube-sig\" >> .mise.local.toml
	echo MINIKUBE_AZ_SUBSCRIPTION_ID=\"$(shell az account show --query 'id' --output tsv)\" >> .mise.local.toml

.PHONY:
preflight: ## Pre-flight checks for azure-* and packer-* targets
	$(if $(strip $(MINIKUBE_AZ_DEPLOYMENT_NAME)),,$(error MINIKUBE_AZ_DEPLOYMENT_NAME is not defined. Export or run make env.))
	$(if $(strip $(MINIKUBE_AZ_RESOURCE_GROUP)),,$(error MINIKUBE_AZ_RESOURCE_GROUP is not defined. Export or run make env.))
	$(if $(strip $(MINIKUBE_AZ_SUBSCRIPTION_ID)),,$(error MINIKUBE_AZ_SUBSCRIPTION_ID is not defined. Export or run make env.))
	@az group show --name "$(MINIKUBE_AZ_RESOURCE_GROUP)" --subscription "$(MINIKUBE_AZ_SUBSCRIPTION_ID)" || \
	( echo "Run 'az group create --name \"$(MINIKUBE_AZ_RESOURCE_GROUP)\" --location \"<your preference>\" to create the resource group." && exit 1 )

##@ Azure Infrastructure

.PHONY:
azure-validate: preflight ## Validate syntax of Bicep templates
	az deployment group validate --no-prompt --verbose \
		--resource-group "$(MINIKUBE_AZ_RESOURCE_GROUP)" \
		--subscription "$(MINIKUBE_AZ_SUBSCRIPTION_ID)" \
		--template-file gallery.bicep \
		--parameters gallery.bicepparam

.PHONY:
azure-what-if: preflight ## Validate Bicep templates for Azure deployment
	az deployment group what-if --verbose \
		--resource-group "$(MINIKUBE_AZ_RESOURCE_GROUP)" \
		--subscription "$(MINIKUBE_AZ_SUBSCRIPTION_ID)" \
		--template-file gallery.bicep \
		--parameters gallery.bicepparam
azure-plan: azure-what-if ## Alias for azure-what-if

.PHONY:
azure-deploy: preflight ## Deploy Bicep templates to Azure as deployment stack
	az stack group create --action-on-unmanage deleteResources --deny-settings-mode None \
		--name "${MINIKUBE_AZ_DEPLOYMENT_NAME}" \
		--resource-group "$(MINIKUBE_AZ_RESOURCE_GROUP)" \
		--subscription "$(MINIKUBE_AZ_SUBSCRIPTION_ID)" \
		--template-file gallery.bicep \
		--parameters gallery.bicepparam

.PHONY:
azure-undeploy: preflight ## Delete deployment stack and its resources from Azure
	az stack group delete --action-on-unmanage deleteResources \
		--name "${MINIKUBE_AZ_DEPLOYMENT_NAME}" \
		--resource-group "$(MINIKUBE_AZ_RESOURCE_GROUP)" \
		--subscription "$(MINIKUBE_AZ_SUBSCRIPTION_ID)"

##@ Bicep

templates := $(shell find . -type f \( -name '*.bicep' -o -name '*.bicepparam' \) )

_bicep-fmt: $(templates:.bicep=.bicep.fmt) $(parameters:.bicepparam=.biceparam.fmt)
bicep-fmt: ## Format Bicep files
	@$(MAKE) _bicep-fmt

_bicep-lint: $(templates:.bicep=.bicep.lint) $(parameters:.bicepparam=.biceparam.lint)
bicep-lint:
	@$(MAKE) _bicep-lint

%.bicep.fmt %.bicepparam.fmt:
	AZURE_BICEP_CHECK_VERSION=False az bicep format --file $(basename $@) --verbose 2>&1

%.bicep.lint %.bicepparam.lint:
	AZURE_BICEP_CHECK_VERSION=False az bicep lint --file $(basename $@) --verbose  2>&1

##@ Packer

.PHONY:
packer-vars: preflight ## Generate packer/azure.auto.pkrvars.hcl with Packer parameters
	echo "# Azure Shared Image Gallery where Packer will  publish the VM image." > packer/azure.auto.pkrvars.hcl
	echo "minikube_resource_group=\"$(MINIKUBE_AZ_RESOURCE_GROUP)\"" >> packer/azure.auto.pkrvars.hcl
	echo "minikube_subscription_id=\"$(MINIKUBE_AZ_SUBSCRIPTION_ID)\"" >> packer/azure.auto.pkrvars.hcl

.PHONY:
packer-fmt: ## Run packer fmt
	packer fmt ./packer

.PHONY:
packer-init: packer-vars ## Run packer init preparing for VM image build 
	packer init ./packer

.PHONY:
packer-validate: packer-init ## Run packer validate
	cd ./packer && packer validate .

.PHONY:
packer-build-and-publish: packer-init ## Run packer build (checks shared image gallery exists, deletes pre-existing image)
	cd ./packer && packer build -force -timestamp-ui -warn-on-undeclared-var .
