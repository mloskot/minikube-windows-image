#!/bin/bash
set -e

# Source environment variables from .envrc
if [ -f .envrc ]; then
    source .envrc
else
    echo "Error: .envrc file not found."
    exit 1
fi

# Ensure required variables are set
if [ -z "$subscription_id" ] || [ -z "$resource_group" ]; then
    echo "Error: subscription_id or resource_group not set in .envrc"
    exit 1
fi

RESOURCE_ID="/subscriptions/${subscription_id}/resourceGroups/${resource_group}"

echo "----------------------------------------------------------------"
echo "Importing Resource Group into Terraform State"
echo "Resource Group: ${resource_group}"
echo "Subscription:   ${subscription_id}"
echo "Resource ID:    ${RESOURCE_ID}"
echo "----------------------------------------------------------------"

# Run the import command
# We use -chdir to execute in the correct directory
terraform -chdir=1-terraform-infrastructure import \
    azurerm_resource_group.main \
    "${RESOURCE_ID}"

echo "----------------------------------------------------------------"
echo "Import completed successfully."
echo "You can now run 'make infra' to apply the rest of the configuration."
