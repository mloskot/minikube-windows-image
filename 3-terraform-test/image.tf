data "azurerm_shared_image_version" "minikube" {
  resource_group_name = data.azurerm_resource_group.test.name
  gallery_name        = "sigmk" # Created by infra

  # image definition
  image_name = "mk-win11" # created by Terraform infra

  # image version
  #name = "latest" # https://learn.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries#image-versions
  name = "1.0.0" # created by Packer build
}
