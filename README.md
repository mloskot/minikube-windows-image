# minikube-windows-image

> [!CAUTION]
> This is an experiment related to https://github.com/kubernetes/minikube/issues/22483

## Usage

```bash
az login
source .envrc # or direnv allow
make infra
make build
make test # outputs SSH/RDP credentials to connect to VM
make test-destroy
```

## Notes

Failed to create VM of size of `Standard_D8s_v3`:

```
Error: creating Windows Virtual Machine
Virtual Machine Name: "vm-test"): performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: InvalidParameter: The VM size 'Standard_D8s_v6' cannot boot with OS image or disk. Please check that disk controller types supported by the OS image or disk is one of the supported disk controller types for the VM size 'Standard_D8s_v6'. Please query sku api at https://aka.ms/azure-compute-skus  to determine supported disk controller types for the VM size.
```

Failed to create VM from VM image `sysprep /unattend:C:\autounatend.xml`

```
│ API Response:
│ 
│ ----[start]----
│ {
│   "startTime": "2026-01-19T20:19:33.6007718+00:00",
│   "endTime": "2026-01-19T20:24:45.8535479+00:00",
│   "status": "Failed",
│   "error": {
│     "code": "OSProvisioningClientError",
│     "message": "OS provisioning for VM 'vm-test' failed. Error details: This installation of Windows is undeployable. Make sure the image has been properly prepared (generalized).\r\nInstructions for Windows: https://learn.microsoft.com/azure/virtual-machines/windows/prepare-for-upload-vhd-image "
│   },
│   "name": "0b434632-9f21-4eee-b7f1-0bed63c66e0f"
│ }
│ -----[end]-----
```

Terraform cannot create VM from spezialized VM image with user credentials specified, but Azure CLI can!

```
│ Error: Invalid combination of arguments
│ 
│   with azurerm_windows_virtual_machine.test,
│   on vm.tf line 1, in resource "azurerm_windows_virtual_machine" "test":
│    1: resource "azurerm_windows_virtual_machine" "test" {
│ 
│ "admin_username": one of `admin_username,os_managed_disk_id` must be specified
```

Username `Administrator` is special and cannot be used with Packer to provision VM:

```
The Admin Username specified is not allowed.
For more information about disallowed usernames, see https://aka.ms/vmosprofile"
```
