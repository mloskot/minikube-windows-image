#!/bin/bash
set -e

PACKER_VERSION="1.14.3"
INSTALL_DIR="/usr/local/bin"

echo "Downloading Packer ${PACKER_VERSION}..."
wget "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" -O packer.zip

echo "Unzipping..."
if ! command -v unzip &> /dev/null; then
    sudo apt-get install -y unzip
fi
unzip -o packer.zip

echo "Installing to ${INSTALL_DIR}..."
sudo mv packer "${INSTALL_DIR}/packer"
sudo chmod +x "${INSTALL_DIR}/packer"

# Cleanup
rm packer.zip

echo "Cleaning up broken apt list..."
sudo rm -f /etc/apt/sources.list.d/hashicorp.list

echo "Packer installed successfully!"
packer --version
