source "azure-arm" "mk-win11" {
  subscription_id    = var.subscription_id
  use_azure_cli_auth = true

  location = var.location

  image_publisher = "MicrosoftWindowsDesktop"
  image_offer     = "Windows-11"
  image_sku       = "win11-25h2-pro"

  vm_size        = "Standard_D8s_v6"
  os_type        = "Windows"
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "5m"
  winrm_username = var.admin_username
  winrm_password = var.admin_password

  shared_image_gallery_destination {
    subscription            = var.subscription_id
    resource_group          = var.resource_group
    gallery_name            = "sigmk"
    image_name              = "mk-win11"
    image_version           = "1.0.0"
    use_shallow_replication = true # https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries#shallow-replication
    specialized             = true # https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries#generalized-and-specialized-images
  }
}