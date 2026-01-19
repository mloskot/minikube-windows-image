output "vm_test" {
  value = {
    state          = azapi_resource.vm_test.output.properties.provisioningState
    resource_group = data.azurerm_resource_group.test.name
    name           = var.vm_name
    public_ip      = azurerm_public_ip.test.ip_address
    admin_username = var.admin_username
    admin_password = var.admin_password # WARNING: Yes, we output sensitive value!
    rdp_url        = "rdp://${var.admin_username}@${azurerm_public_ip.test.ip_address}"
    rdp_file       = local_file.rdp_file.filename
  }
}

resource "local_file" "rdp_file" {
  depends_on = [azurerm_public_ip.test, azapi_resource.vm_test]

  filename        = "${path.module}/${local.rdp_filename}"
  file_permission = "0600"
  content         = <<EOF
full address:s:${azurerm_public_ip.test.ip_address}:3389
username:s:${var.admin_username}
password:s:${var.admin_password}
prompt for credentials:i:1
administrative session:i:1
redirectclipboard:i:1
EOF
}
