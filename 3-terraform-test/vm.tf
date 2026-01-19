# Build VM from specialized image, not generalized.
#
# Because VM is created from specialized image, it already contain required configuration,
# VM will boot exactly as captured with all accounts, passwords, and machine identity intact.
# Therefore, when creating VM from specialized image, the following properties must be set:
#   - osProfile omitted entirely, Azure will reject the deployment if osProfile is included
#   - storageProfile.osDisk.createOption = "FromImage"
#   - storageProfile.osDisk.osType must be set explicitly

resource "azapi_resource" "vm_test" {
  type      = "Microsoft.Compute/virtualMachines@2023-03-01"
  name      = var.vm_name
  location  = data.azurerm_resource_group.test.location
  parent_id = data.azurerm_resource_group.test.id

  body = {
    properties = {
      hardwareProfile = {
        vmSize = "Standard_D2_v5"
      }
      storageProfile = {
        imageReference = {
          id = data.azurerm_shared_image_version.minikube.id
        }

        osDisk = {
          createOption = "FromImage"
          osType       = "Windows"
          managedDisk = {
            storageAccountType = "Standard_LRS"
          }
        }
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azurerm_network_interface.test.id
          }
        ]
      }
    }
  }
  response_export_values = [
    "properties.provisioningState"
  ]
}

# HACK: Although Azure CLI works, it is very not Terraform friendly
# resource "null_resource" "vm_test" {
#   depends_on = [azurerm_network_interface.test]
#   provisioner "local-exec" {
#     environment = {
#       AZ_RESOURCE_GROUP    = data.azurerm_resource_group.test.name
#       AZ_VM_IMAGE_ID       = data.azurerm_shared_image_version.minikube.id
#       AZ_VM_NIC_ID         = azurerm_network_interface.test.id
#       AZ_VM_ADMIN_USERNAME = var.admin_username
#       AZ_VM_ADMIN_PASSWORD = var.admin_password
#     }
#     interpreter = ["/bin/bash", "-c"]
#     command     = "echo" #"./scripts/az-vm-create.sh"
#   }
#   triggers = {
#     source_image_id = data.azurerm_shared_image_version.minikube.id
#     #always_run = timestamp()
#   }
# }

# NOTE: Terraform cannot create VM from spezialized VM image with user credentials specified, but Azure CLI can!
# resource "azurerm_windows_virtual_machine" "test" {
#   name                = var.vm_name"
#   location            = data.azurerm_resource_group.test.location
#   resource_group_name = data.azurerm_resource_group.test.name
#   source_image_id     = data.azurerm_shared_image_version.minikube.id
#   size                = "Standard_B2ms"
#   admin_username      = var.admin_username
#   admin_password      = var.admin_password
#   network_interface_ids = [
#     azurerm_network_interface.test.id,
#   ]
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }
# }
