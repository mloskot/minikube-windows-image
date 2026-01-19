#!/bin/bash
set -e

VM_ID_OR_NAME="$1"
[ -z "${VM_ID_OR_NAME}" ] && { echo "VM id or name is empty"; exit 1; }
VM_GROUP="$2"

if [ "${VM_ID_OR_NAME:0:13}" = /subscription ]; then
  VM_ID="${VM_ID_OR_NAME}"
elif [ "${VM_ID_OR_NAME:0:13}" = /subscription ] && [ -n "${VM_GROUP}" ]; then
  VM_ID="$(az vm show --resource-group "${VM_GROUP}" --name "${VM_ID_OR_NAME}")"
else
  echo "Usage: $(basename "${0}") <VM id>"
  echo "Usage: $(basename "${0}") <VM name> <VM resource group name>"
  exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting ${VM_ID}..."

VM_OSDISK_DELETE=$(az vm show --ids "${VM_ID}" --query 'storageProfile.osDisk.deleteOption' --output tsv)
if [ "${VM_OSDISK_DELETE}" != "Delete" ]; then
    VM_OSDISK=$(az vm show --ids "${VM_ID}" --query 'storageProfile.osDisk.name' --output tsv)
fi
VM_NIC=$(az vm show --ids "${VM_ID}" --query 'networkProfile.networkInterfaces[].id' --output tsv)
VM_PIP=$(az network nic show --ids "${VM_NIC}" --query 'ipConfigurations[].publicIPAddress.id' --output tsv)

env | grep -E "^VM_*"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting VM..."
az vm delete --ids "${VM_ID}" --yes
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting VM done"

if [ -n "${VM_OSDISK}" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting OS disk..."
  az disk delete --ids "${VM_OSDISK}" --yes
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting OS disk done"
fi

if [ -n "${VM_NIC}" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting NIC..."
  az network nic delete --ids "${VM_NIC}" # --yes not available
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting done"
fi

if [ -n "${VM_PIP}" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting public IP..."
  az network public-ip delete --ids "${VM_PIP}" # --yes not available
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting public IP done"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleting VM done"
