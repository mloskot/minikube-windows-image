locals {
  rdp_filename = (
    azurerm_public_ip.test.ip_address != "" ?
    "connect-vm-${replace(azurerm_public_ip.test.ip_address, ".", "-")}.rdp" :
    "connect-vm-pending-public-ip.rdp"
  )
}
