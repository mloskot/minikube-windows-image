.DEFAULT_GOAL := help

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

INFRA_DIR := 1-terraform-infrastructure
BUILD_DIR := 2-packer-build
TEST_DIR := 3-terraform-test

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ General

.PHONY: all
all: | infra build test ## Runs infra, build and test workflows

.PHONY: clean
clean:
	rm -f $(shell find . -name '*.auto*')
	rm -f $(shell find . -name '*.tfplan')

.PHONY: init
init: | infra-init build-init test-init ## Initialize all configurations

.PHONY: fmt
fmt: | infra-fmt build-fmt test-fmt ## Format all configuration templates

.PHONY: validate
validate: | infra-validate build-validate test-validate ## Validate all configuration templates

.PHONY: lint
lint: | fmt validate

##@ Infrastructure

.PHONY: infra
infra: | infra-init infra-fmt infra-validate infra-plan infra-apply ## Create or update infrastructure with terraform

.PHONY: infra-init
infra-init: ## Initialize terraform for infrastructure
	terraform -chdir=$(INFRA_DIR) init -upgrade

.PHONY: infra-plan
infra-plan: infra-vars infra.tfplan ## Run terraform plan for infrastructure

infra.tfplan:
	terraform -chdir=$(INFRA_DIR) plan -out infra.tfplan -lock=false

.PHONY: infra-apply
infra-apply: infra-plan ## Run terraform apply for infrastructure
	terraform -chdir=$(INFRA_DIR) apply -lock=false infra.tfplan

.PHONY: infra-fmt
infra-fmt: ## Run terraform fmt for infrastructure
	terraform -chdir=$(INFRA_DIR) fmt

.PHONY: infra-validate
infra-validate: infra-vars ## Run terraform validate for infrastructure
	terraform -chdir=$(INFRA_DIR) validate

.PHONY: infra-vars
infra-vars: ## Generate input variables for terraform
	cp .secrets.vars $(INFRA_DIR)/secrets.auto.tfvars

##@ Build image

.PHONY: build
build: | build-init build-fmt build-validate build-image ## Create or update test VM infrastructure

.PHONY: build-init
build-init: ## Run packer init for VM testing
	packer init $(BUILD_DIR)

.PHONY: build-fmt
build-fmt: ## Run packer fmt for VM testing
	packer fmt $(BUILD_DIR)

.PHONY: build-validate
build-validate: build-vars ## Run packer validate for VM testing
	cd $(BUILD_DIR) && packer validate .

.PHONY: build-image
build-image: build-vars ## Run packer build for VM testing
	cd $(BUILD_DIR) && packer build -force -timestamp-ui -warn-on-undeclared-var .

.PHONY: build-vars
build-vars: ## Generate input variables for packer build
	cp .secrets.vars $(BUILD_DIR)/secrets.auto.pkrvars.hcl
	cp credentials.vars $(BUILD_DIR)/credentials.auto.pkrvars.hcl

##@ Test image

.PHONY: test
test: | test-init test-fmt test-validate test-plan test-apply ## Create or update infrastructure with terraform

.PHONY: test-init
test-init: ## Run terraform init for VM testing
	terraform -chdir=$(TEST_DIR) init -upgrade

.PHONY: test-plan
test-plan: test-vars test.tfplan ## Run terraform plan for VM testing

test.tfplan:
	terraform -chdir=$(TEST_DIR) plan -out test.tfplan -lock=false

.PHONY: test-apply
test-apply: test-plan ## Run terraform apply for VM testing
	terraform -chdir=$(TEST_DIR) apply -lock=false -auto-approve test.tfplan

.PHONY: test-fmt
test-fmt: ## Run terraform fmt for VM testing
	terraform -chdir=$(TEST_DIR) fmt

.PHONY: test-validate
test-validate: test-vars ## Run terraform validate for VM testing
	terraform -chdir=$(TEST_DIR) validate

.PHONY: test-vars
test-vars: ## Generate input variables for test
	cp .secrets.vars $(TEST_DIR)/secrets.auto.tfvars
	cp credentials.vars $(TEST_DIR)/credentials.auto.tfvars

.PHONY: test-destroy
test-destroy: test-vars ## Destroy only the test VM
	terraform -chdir=$(TEST_DIR) plan -destroy -out destroy.tfplan -lock=false
	terraform -chdir=$(TEST_DIR) apply -destroy -auto-approve -lock=false destroy.tfplan
