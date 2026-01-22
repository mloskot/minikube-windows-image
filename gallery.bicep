targetScope = 'resourceGroup'

param location string = resourceGroup().location
param imageName string = 'minikube-windows-11' // TODO: Load from env and Packer vm_image_name accordingly?
param sharedImageGalleryName string = 'minikube' // TODO: Load from env?

@onlyIfNotExists()
resource sig 'Microsoft.Compute/galleries@2024-03-03' = {
  name: sharedImageGalleryName
  location: location
  tags: {}
  properties: {
    description: 'Gallery with specialized VM images for Minikube'
    identifier: {}
  }
}

@onlyIfNotExists()
resource image 'Microsoft.Compute/galleries/images@2024-03-03' = {
  location: location
  name: imageName 
  parent: sig
  tags: {}
  properties: {
    description: 'Minimal Windows 11 image for Minikube'
    identifier: {
      publisher: 'mloskot'
      offer: 'minikube'
      sku: 'windows-11'
    }
    architecture: 'x64'
    hyperVGeneration: 'V2'
    osState: 'Specialized'
    osType: 'Windows'
  }
}
