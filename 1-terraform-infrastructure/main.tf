resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_shared_image_gallery" "main" {
  name                = "sigmk" # used by Packer and test Terraform config
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_shared_image" "main" {
  name                = "mk-win11" # Packer: managed_image_name
  gallery_name        = azurerm_shared_image_gallery.main.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Windows"
  architecture        = "x64"
  hyper_v_generation  = "V2"
  specialized         = true
  identifier {
    publisher = "mloskot"
    offer     = "mk"
    sku       = "win11"
  }
}
