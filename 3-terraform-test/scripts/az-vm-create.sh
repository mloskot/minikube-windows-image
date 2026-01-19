#!/bin/bash
# Terraform cannot create VM from a specialized image with admin_username/admin_password,
# so we use Azure CLI here. See https://github.com/hashicorp/terraform-provider-azurerm/pull/7524

echo "$(printf '%(%F %T)T') Creating VM from ${AZ_VM_IMAGE_ID}..." >&2

env | grep '^AZ_'

az vm create\
   --resource-group "${AZ_RESOURCE_GROUP}"  \
   --name "vm-test" \
   --size "Standard_D2_v5" \
   --image "${AZ_VM_IMAGE_ID}" \
   --specialized \
   --admin-username "${AZ_VM_ADMIN_USERNAME}" \
   --admin-password "${AZ_VM_ADMIN_PASSWORD}" \
   --nics "${AZ_VM_NIC_ID}"

echo "$(printf '%(%F %T)T') Creating VM completed" >&2
