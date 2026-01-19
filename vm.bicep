// Requires prior deployment of Shared Image Gallery (SIG) and Virtual Network (VNet)
targetScope = 'resourceGroup'

// vm.bicepparam
param sigName string
param sigImageDefinitionName string
param sigImageVersion string
param nsgName string
param vnetName string
param vmName string
param vmSize string

var location string = resourceGroup().location
var ipConfigurationName string = '${vmName}-ipc' // azure will append random unique suffix
var networkInterfaceName string = '${vmName}-nic' // azure will append random unique suffix
var publicIpName string = '${vmName}-pip' // azure will append random unique suffix

resource sig 'Microsoft.Compute/galleries@2025-03-03' existing = {
  name: sigName
}

resource sigImageDefinition 'Microsoft.Compute/galleries/images@2025-03-03' existing = {
  name: sigImageDefinitionName
  parent: sig
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: vnetName
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-05-01' existing = {
  name: nsgName
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    networkProfile: {
      networkApiVersion: '2025-05-01'
      networkInterfaceConfigurations: [
        {
          name: networkInterfaceName
          properties: {
            deleteOption: 'Delete'
            ipConfigurations: [
              {
                name: ipConfigurationName
                properties: {
                  primary: true
                  publicIPAddressConfiguration: {
                    name: publicIpName
                    properties: {
                      deleteOption: 'Delete'
                      dnsSettings: {
                        domainNameLabel: vmName
                      }
                      publicIPAddressVersion: 'IPv4'
                      publicIPAllocationMethod: 'Static' // Dynamic: Standard sku publicIp /subscriptions/... must have AllocationMethod set to Static.
                    }
                    sku: { name: 'Standard' } // Basic: Cannot create more than 0 IPv4 Basic SKU public IP addresses for this subscription in this region.
                    tags: { project: 'minikube', vm: vmName }
                  }
                  subnet: {
                    id: '${virtualNetwork.id}/subnets/${virtualNetwork.properties.subnets[0].name}'
                  }
                }
              }
            ]
            networkSecurityGroup: {
              id: networkSecurityGroup.id
            }
          }
          tags: { project: 'minikube', vm: vmName }
        }
      ]
    }
    //osProfile: {} // Parameter OSProfile is not allowed with a specialized image.
    storageProfile: {
      imageReference: {
        id: '${sig.id}/images/${sigImageDefinition.name}/versions/${sigImageVersion}'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
    }
  }
  tags: { project: 'minikube', vm: vmName }
}

output vmId string = virtualMachine.id
