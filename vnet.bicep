targetScope = 'resourceGroup'

// vnet.bicepparam
param nsgName string
param vnetName string

var location string = resourceGroup().location
var subnetName string = '${vnetName}-snet'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: nsgName
  location: location
  tags: { project: 'minikube' }
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          direction: 'Inbound'
          priority: 1000
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSSH'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
          direction: 'Inbound'
          priority: 1001
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: vnetName
  location: location
  tags: { project: 'minikube' }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

output vmVirtualNetworkId string = virtualNetwork.id
output vmVirtualNetworkName string = virtualNetwork.name
output vmSubnetId string = '${virtualNetwork.id}/subnets/${subnetName}'
output vmSubnetName string = subnetName
