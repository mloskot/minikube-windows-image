#!/bin/bash
set -e

# Source environment variables
if [ -f .envrc ]; then
    source .envrc
else
    echo "Error: .envrc file not found in current directory."
    echo "Please run this script from the root of the workspace."
    exit 1
fi

if [ -z "$subscription_id" ] || [ -z "$resource_group" ]; then
    echo "Error: variables not set in .envrc"
    exit 1
fi

GALLERY_NAME="sigmk"
IMAGE_NAME="mk-win11"

GALLERY_ID="/subscriptions/${subscription_id}/resourceGroups/${resource_group}/providers/Microsoft.Compute/galleries/${GALLERY_NAME}"
IMAGE_ID="${GALLERY_ID}/images/${IMAGE_NAME}"

echo "----------------------------------------------------------------"
echo "Importing Shared Image Gallery and Image Definition"
echo "Gallery ID: ${GALLERY_ID}"
echo "Image ID:   ${IMAGE_ID}"
echo "----------------------------------------------------------------"

# Import Gallery
echo "Importing azurerm_shared_image_gallery..."
terraform -chdir=1-terraform-infrastructure import -lock=false \
    azurerm_shared_image_gallery.main \
    "${GALLERY_ID}"

# Import Image Definition
echo "Importing azurerm_shared_image..."
terraform -chdir=1-terraform-infrastructure import -lock=false \
    azurerm_shared_image.main \
    "${IMAGE_ID}"

echo "----------------------------------------------------------------"
echo "Import completed successfully."
